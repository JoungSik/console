require "application_system_test_case"

class HotwireNativeLayoutTest < ApplicationSystemTestCase
  NATIVE_USER_AGENT = "Console Hotwire Native iOS"

  test "Native 공개 화면은 불필요한 상단 여백과 문서 overflow가 없다" do
    use_mobile_viewport
    original_user_agent = page.evaluate_script("navigator.userAgent")
    set_user_agent(NATIVE_USER_AGENT)

    begin
      assert_legal_page_top_spacing(privacy_url)
      assert_legal_page_top_spacing(terms_url)

      user = users(:test_user)
      compact_page_paths = [
        new_session_url,
        new_registration_url,
        verify_pending_registration_url,
        new_password_url,
        edit_password_url(user.password_reset_token)
      ]
      compact_page_paths.each { |path| assert_no_document_overflow(path) }
    ensure
      set_user_agent(original_user_agent)
    end
  end

  private

  def set_user_agent(user_agent)
    page.driver.browser.execute_cdp("Network.setUserAgentOverride", userAgent: user_agent)
  end

  def assert_legal_page_top_spacing(path)
    visit path
    assert_selector ".legal-content > h2:first-child"

    spacing = page.evaluate_script(<<~JS)
      (() => {
        const main = document.querySelector("main")
        const pageRoot = main.firstElementChild
        const firstHeading = document.querySelector(".legal-content > h2:first-child")

        return {
          mainTop: main.getBoundingClientRect().top,
          pageRootTop: pageRoot.getBoundingClientRect().top,
          firstHeadingMarginTop: parseFloat(getComputedStyle(firstHeading).marginTop)
        }
      })()
    JS

    assert_in_delta spacing["mainTop"], spacing["pageRootTop"], 1,
      "#{path}의 Native 본문은 main 상단에서 바로 시작해야 합니다"
    assert_in_delta 0, spacing["firstHeadingMarginTop"], 1,
      "#{path}의 첫 본문 제목에는 숨겨진 페이지 제목의 여백이 남지 않아야 합니다"
  end

  def assert_no_document_overflow(path)
    visit path
    assert_selector "main"

    dimensions = page.evaluate_script(<<~JS)
      ({
        viewportHeight: document.documentElement.clientHeight,
        documentHeight: document.documentElement.scrollHeight
      })
    JS

    assert_operator dimensions["documentHeight"], :<=, dimensions["viewportHeight"] + 1,
      "#{path}에 불필요한 Native 문서 스크롤이 없어야 합니다"
  end
end
