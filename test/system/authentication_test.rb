require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
  end

  test "로그인에 성공하면 홈 화면으로 이동한다" do
    sign_in_as @user
    assert_current_path root_path
  end

  test "잘못된 자격증명으로 로그인하면 오류 메시지가 표시된다" do
    visit new_session_url
    fill_in "email_address", with: "test@example.com"
    fill_in "password", with: "wrong"
    click_button I18n.t("forms.buttons.sign_in")
    assert_text I18n.t("messages.errors.invalid_credentials")
  end

  test "로그아웃하면 로그인 페이지로 이동한다" do
    sign_in_as @user
    page.accept_confirm I18n.t("confirmations.logout") do
      click_link I18n.t("navigation.logout")
    end
    assert_current_path new_session_path
  end
end
