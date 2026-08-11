require "application_system_test_case"

class ResponsivePagesTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
    @post = Journal::Post.create!(body: "반응형 포스트", user_id: @user.id)
    @list = Todo::List.create!(title: "반응형 목록", user_id: @user.id)
    @list.items.create!(title: "반응형 할 일", due_date: Date.current)
  end

  test "모든 공개 사용자 화면은 데스크톱과 모바일 viewport 안에서 동작한다" do
    public_pages = [
      [ root_url, "a" ],
      [ new_session_url, "form" ],
      [ new_registration_url, "form" ],
      [ verify_pending_registration_url, "main" ],
      [ new_password_url, "form" ],
      [ edit_password_url(@user.password_reset_token), "form" ],
      [ terms_url, ".legal-content" ],
      [ privacy_url, ".legal-content" ]
    ]

    [ DESKTOP_VIEWPORT, MOBILE_VIEWPORT ].each do |viewport|
      resize_browser_to(*viewport)
      public_pages.each { |url, action_selector| assert_responsive_page(url, action_selector) }
    end
  end

  test "모든 인증 사용자 화면은 데스크톱과 모바일 viewport 안에서 동작한다" do
    authenticated_pages = [
      [ root_url, "main" ],
      [ mypage_user_url, "form" ],
      [ mypage_plugins_url, "#plugin_posts button" ],
      [ mypage_push_notifications_url, "[data-controller~='web-push-subscription'] button" ],
      [ posts.root_url, "#post_composer form" ],
      [ posts.post_url(@post), "#post_#{@post.id}" ],
      [ posts.edit_post_url(@post), "form" ],
      [ todo.lists_url, "a[href='#{todo.new_list_path}']" ],
      [ todo.new_list_url, "form" ],
      [ todo.list_url(@list), "#list_items button" ],
      [ todo.edit_list_url(@list), "form" ]
    ]

    [ DESKTOP_VIEWPORT, MOBILE_VIEWPORT ].each do |viewport|
      resize_browser_to(*viewport)
      sign_in_as @user

      authenticated_pages.each do |url, action_selector|
        assert_responsive_page(url, action_selector)
        assert_navigation_for(viewport)
      end

      page.reset!
    end
  end

  test "Todo 카드 grid와 action 영역은 viewport에 맞춰 열과 행을 전환한다" do
    2.times { |index| Todo::List.create!(title: "추가 목록 #{index}", user_id: @user.id) }
    sign_in_as @user

    use_desktop_viewport
    visit todo.lists_url
    desktop_layout = todo_index_layout
    assert_equal 3, desktop_layout["cardColumns"]
    assert_in_delta desktop_layout["titleTop"], desktop_layout["actionTop"], 1

    use_mobile_viewport
    visit todo.lists_url
    mobile_layout = todo_index_layout
    assert_equal 1, mobile_layout["cardColumns"]
    assert_operator mobile_layout["actionTop"], :>, mobile_layout["titleBottom"]
    assert_no_horizontal_overflow
  end

  private

  def assert_responsive_page(url, action_selector)
    visit url
    assert_selector "main", visible: true
    assert_selector action_selector, visible: true
    assert_no_horizontal_overflow
    assert_element_within_viewport("main")
  end

  def assert_navigation_for(viewport)
    if viewport == DESKTOP_VIEWPORT
      assert_selector "nav[aria-label='Sidebar']", visible: true
      assert_selector "nav[aria-label='Bottom navigation']", visible: false
    else
      assert_selector "nav[aria-label='Sidebar']", visible: false
      assert_selector "nav[aria-label='Bottom navigation']", visible: true
    end
  end

  def todo_index_layout
    page.evaluate_script(<<~JS)
      (() => {
        const cards = [...document.querySelectorAll("#lists .group")].map((element) => element.getBoundingClientRect());
        const title = document.querySelector("h1").getBoundingClientRect();
        const action = document.querySelector("a[href='#{todo.new_list_path}']").getBoundingClientRect();
        const cardColumns = new Set(cards.map((card) => Math.round(card.left))).size;

        return {
          cardColumns,
          titleTop: title.top,
          titleBottom: title.bottom,
          actionTop: action.top
        };
      })()
    JS
  end
end
