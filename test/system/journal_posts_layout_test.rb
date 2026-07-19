require "application_system_test_case"

class JournalPostsLayoutTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
    Journal::Post.create!(body: "레이아웃 확인용 포스트", user_id: @user.id)
    sign_in_as @user
  end

  teardown do
    resize_browser_to(1400, 1400)
  end

  test "데스크톱에서는 작성 영역과 피드가 나란히 표시된다" do
    resize_browser_to(1920, 1000)
    visit posts.root_url

    page_container, composer, feed, main_content_width = post_layout_positions

    assert_in_delta main_content_width, page_container["width"], 1
    assert_in_delta composer["width"] * 2, feed["width"], 1
    assert_operator feed["left"] - composer["right"], :>=, 32
    assert_in_delta composer["top"], feed["top"], 1
  end

  test "모바일에서는 작성 영역 뒤에 피드가 표시된다" do
    resize_browser_to(390, 844)
    visit posts.root_url

    _page_container, composer, feed, _main_content_width = post_layout_positions

    assert_operator feed["top"], :>, composer["bottom"]
    assert_in_delta composer["left"], feed["left"], 1
  end

  private

  def resize_browser_to(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
  end

  def post_layout_positions
    layout = page.evaluate_script(<<~JS)
      (() => {
        const pageContainer = document.querySelector("#posts-page").getBoundingClientRect();
        const main = document.querySelector("main");
        const mainStyles = window.getComputedStyle(main);
        const composer = document.querySelector("#post-composer").getBoundingClientRect();
        const feed = document.querySelector("#posts").getBoundingClientRect();

        return {
          pageContainer: { width: pageContainer.width },
          composer: { left: composer.left, right: composer.right, top: composer.top, bottom: composer.bottom, width: composer.width },
          feed: { left: feed.left, top: feed.top, width: feed.width },
          mainContentWidth: main.clientWidth - parseFloat(mainStyles.paddingLeft) - parseFloat(mainStyles.paddingRight)
        };
      })()
    JS

    [ layout["pageContainer"], layout["composer"], layout["feed"], layout["mainContentWidth"] ]
  end
end
