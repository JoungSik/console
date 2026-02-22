require "application_system_test_case"

class MypageTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
  end

  test "프로필 정보가 표시된다" do
    sign_in_as @user
    visit mypage_user_url
    assert_text @user.name
    assert_text @user.email_address
  end

  test "비밀번호를 변경하면 재로그인이 필요하다" do
    sign_in_as @user
    visit mypage_user_url
    fill_in I18n.t("settings.password.current_password"), with: "password123"
    fill_in I18n.t("settings.password.new_password"), with: "newpassword456"
    fill_in I18n.t("settings.password.confirm_password"), with: "newpassword456"
    click_button I18n.t("settings.password.change_button")
    assert_current_path new_session_path
    assert_text I18n.t("settings.password.updated_please_login")
  end
end
