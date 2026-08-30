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

  test "테마를 선택하면 즉시 적용되고 저장된다" do
    sign_in_as @user
    click_link I18n.t("navigation.mypage")
    assert_current_path mypage_user_path

    find("label[for='theme_value_dark']").click
    assert page.evaluate_script("document.documentElement.classList.contains('dark')")
    assert page.evaluate_script("document.documentElement.classList.contains('theme-dark')")
    assert_text I18n.t("settings.theme.updated")
    assert @user.reload.theme_dark?
    assert_current_path mypage_user_path

    page.execute_script(<<~JS)
      document.body.dataset.themePreference = "system"
      document.dispatchEvent(new CustomEvent("turbo:render", { detail: { renderMethod: "replace" } }))
    JS
    assert page.evaluate_script("document.documentElement.classList.contains('dark')")

    page.go_back
    assert_current_path root_path
    assert page.evaluate_script("document.documentElement.classList.contains('dark')")

    visit mypage_user_url

    find("label[for='theme_value_light']").click
    assert_not page.evaluate_script("document.documentElement.classList.contains('dark')")
    assert page.evaluate_script("document.documentElement.classList.contains('theme-light')")
    assert_text I18n.t("settings.theme.updated")
    assert @user.reload.theme_light?
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

  test "현재 비밀번호와 최종 확인을 거쳐 회원 탈퇴한다" do
    sign_in_as @user
    visit mypage_user_url

    assert_text I18n.t("settings.account_deletion.warning")
    fill_in I18n.t("settings.account_deletion.current_password"), with: "password123"

    accept_confirm I18n.t("settings.account_deletion.confirmation") do
      click_button I18n.t("settings.account_deletion.delete_button")
    end

    assert_current_path root_path
    assert_text I18n.t("settings.account_deletion.deleted")
    assert_not User.exists?(@user.id)
  end
end
