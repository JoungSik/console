require "test_helper"

class PagesTest < ActionDispatch::IntegrationTest
  NATIVE_HEADERS = { "User-Agent" => "Console Hotwire Native iOS" }.freeze

  setup do
    @user = users(:test_user)
  end

  test "미인증 사용자가 이용약관 페이지에 접근할 수 있다" do
    get terms_url
    assert_response :success
    assert_select "h1", I18n.t("pages.terms")
    assert_select ".legal-content", text: /포스트 기록/
  end

  test "미인증 사용자가 개인정보처리방침 페이지에 접근할 수 있다" do
    get privacy_url
    assert_response :success
    assert_select "h1", I18n.t("pages.privacy")
    assert_select ".legal-content", text: /포스트 본문/
    assert_select "a[href='mailto:support@joungsik.com']", text: "support@joungsik.com"
  end

  test "인증된 사용자가 이용약관 페이지에 접근할 수 있다" do
    sign_in_as @user
    get terms_url
    assert_response :success
  end

  test "인증된 사용자가 개인정보처리방침 페이지에 접근할 수 있다" do
    sign_in_as @user
    get privacy_url
    assert_response :success
  end

  test "로그인 페이지에 이용약관 링크가 있다" do
    get new_session_url
    assert_response :success
    assert_select "a[href=?]", terms_path, text: I18n.t("pages.terms")
    assert_select "a[href=?]", privacy_path, text: I18n.t("pages.privacy")
  end

  test "Native 법률 페이지는 제목 위의 여백을 제거한다" do
    [ terms_url, privacy_url ].each do |url|
      get url, headers: NATIVE_HEADERS

      assert_response :success
      assert_select "[data-native-top-flush] [data-native-page-title]", count: 1
      assert_select ".legal-content > h2:first-child", count: 1
    end
  end
end
