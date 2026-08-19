require "test_helper"

class HotwireNativePageContractTest < ActionDispatch::IntegrationTest
  NATIVE_HEADERS = { "User-Agent" => "Console Hotwire Native iOS" }.freeze
  TOP_PADDING_CLASS = /\A(?:[a-z]+:)*(?:pt|py)-/.freeze

  setup do
    @user = users(:test_user)
    @post = Journal::Post.create!(body: "Native 페이지 계약", user_id: @user.id)
    @list = Todo::List.create!(title: "Native 페이지 계약", user_id: @user.id)
    @notice = Notice.create!(title: "Native 공지", published_on: Date.current, position: 1)
  end

  test "공개 페이지가 Native 제목과 상단 여백 계약을 지킨다" do
    pages = {
      root_url => "Console",
      new_session_url => I18n.t("forms.buttons.sign_in"),
      new_registration_url => I18n.t("forms.buttons.sign_up"),
      verify_pending_registration_url => I18n.t("registrations.verify_pending.title"),
      new_password_url => I18n.t("forms.buttons.forgot_password"),
      edit_password_url(@user.password_reset_token) => I18n.t("forms.buttons.reset_password"),
      terms_url => I18n.t("pages.terms"),
      privacy_url => I18n.t("pages.privacy")
    }

    pages.each { |path, title| assert_native_page_contract(path, title:) }
  end

  test "인증 페이지가 Native 제목과 상단 여백 계약을 지킨다" do
    sign_in_as @user

    pages = {
      root_url => "대시보드",
      notice_url(@notice) => @notice.title,
      mypage_user_url => I18n.t("settings.mypage.title"),
      mypage_plugins_url => I18n.t("settings.plugins.title"),
      mypage_push_notifications_url => I18n.t("settings.push_notifications.page_title"),
      posts.root_url => "포스트",
      posts.post_url(@post) => "포스트 상세",
      posts.edit_post_url(@post) => "포스트 수정",
      todo.lists_url => "할 일 목록",
      todo.list_url(@list) => @list.title,
      todo.new_list_url => "새 할 일 목록",
      todo.edit_list_url(@list) => "할 일 목록 수정"
    }

    pages.each { |path, title| assert_native_page_contract(path, title:) }
  end

  private

  def assert_native_page_contract(path, title:)
    get path, headers: NATIVE_HEADERS

    assert_response :success, "#{path} Native 요청이 성공해야 합니다"
    assert_select "link[rel='stylesheet'][href*='hotwire_native']", count: 1
    assert_select "main.px-4.pb-4", count: 1
    assert_select "main.p-8", count: 0
    assert_page_title(path, title)
    assert_visible_headings_are_marked(path)
    assert_top_padding_is_flushable(path)
  end

  def assert_page_title(path, expected_title)
    actual_title = css_select("title").first&.text&.strip
    assert_equal expected_title, actual_title, "#{path}의 title이 화면 제목과 일치해야 합니다"
  end

  def assert_visible_headings_are_marked(path)
    css_select("h1").each do |heading|
      marked = heading.attribute("data-native-page-title").present? ||
        heading.ancestors.any? { |ancestor| ancestor.attribute("data-native-page-title").present? }

      assert marked, "#{path}의 h1은 data-native-page-title 영역에 있어야 합니다"
    end
  end

  def assert_top_padding_is_flushable(path)
    css_select("[data-native-page-title]").each do |title_region|
      title_region.ancestors.take_while { |ancestor| ancestor.name != "main" }.each do |ancestor|
        next unless ancestor.classes.any? { |class_name| class_name.match?(TOP_PADDING_CLASS) }

        assert ancestor.attribute("data-native-top-flush").present?,
          "#{path}에서 제목 위 padding을 가진 영역은 data-native-top-flush가 필요합니다"
      end
    end
  end
end
