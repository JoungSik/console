require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  DESKTOP_VIEWPORT = [ 1440, 1000 ].freeze
  MOBILE_VIEWPORT = [ 390, 844 ].freeze

  driven_by :selenium, using: :headless_chrome, screen_size: DESKTOP_VIEWPORT

  setup do
    Rails.cache.clear
    resize_browser_to(*DESKTOP_VIEWPORT)
  end

  teardown do
    Rails.cache.clear
    resize_browser_to(*DESKTOP_VIEWPORT)
  end

  def sign_in_as(user, password: "password123")
    visit new_session_url
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button I18n.t("forms.buttons.sign_in")
    assert_current_path root_path
  end

  def resize_browser_to(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
  end

  def use_desktop_viewport
    resize_browser_to(*DESKTOP_VIEWPORT)
  end

  def use_mobile_viewport
    resize_browser_to(*MOBILE_VIEWPORT)
  end

  def assert_no_horizontal_overflow
    dimensions = page.evaluate_script(<<~JS)
      ({
        viewportWidth: document.documentElement.clientWidth,
        documentWidth: document.documentElement.scrollWidth
      })
    JS

    assert_operator dimensions["documentWidth"], :<=, dimensions["viewportWidth"],
      "페이지에 수평 overflow가 없어야 합니다"
  end

  def assert_element_within_viewport(selector)
    bounds = page.evaluate_script(<<~JS, selector)
      ((selector) => {
        const element = document.querySelector(selector);
        if (!element) return null;

        const rect = element.getBoundingClientRect();
        return {
          left: rect.left,
          right: rect.right,
          top: rect.top,
          bottom: rect.bottom,
          viewportWidth: document.documentElement.clientWidth,
          viewportHeight: window.innerHeight
        };
      })(arguments[0])
    JS

    assert bounds, "#{selector} 요소가 존재해야 합니다"
    assert_operator bounds["left"], :>=, 0
    assert_operator bounds["right"], :<=, bounds["viewportWidth"]
    assert_operator bounds["top"], :>=, 0
    assert_operator bounds["top"], :<, bounds["viewportHeight"]
  end
end
