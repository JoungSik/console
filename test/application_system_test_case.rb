require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # System 테스트용 브라우저 로그인 헬퍼
  def sign_in_as(user, password: "password123")
    visit new_session_url
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button I18n.t("forms.buttons.sign_in")
    assert_current_path root_path
  end
end
