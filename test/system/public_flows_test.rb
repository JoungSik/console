require "application_system_test_case"

class PublicFlowsTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
  end

  test "회원가입 검증 오류와 약관 동의 후 가입 완료를 확인한다" do
    visit new_registration_url
    fill_in "user[name]", with: "신규 사용자"
    fill_in "user[email_address]", with: "invalid-signup@example.com"
    fill_in "user[password]", with: "weak"
    fill_in "user[password_confirmation]", with: "weak"
    check "terms_agreed"
    check "privacy_agreed"
    click_button I18n.t("forms.buttons.sign_up")

    assert_text "너무 짧습니다"
    assert_field "user[email_address]", with: "invalid-signup@example.com"
    assert_checked_field "terms_agreed"
    assert_checked_field "privacy_agreed"

    fill_in "user[email_address]", with: "system-signup@example.com"
    fill_in "user[password]", with: "password1"
    fill_in "user[password_confirmation]", with: "password1"
    click_button I18n.t("forms.buttons.sign_up")

    assert_current_path verify_pending_registration_path
    assert_text I18n.t("registrations.verify_pending.title")
    assert User.exists?(email_address: "system-signup@example.com")
  end

  test "비밀번호 재설정 요청과 오류와 완료를 확인한다" do
    visit new_password_url
    fill_in "email_address", with: @user.email_address
    click_button I18n.t("forms.buttons.email_reset_instructions")

    assert_current_path new_session_path
    assert_text I18n.t("messages.success.password_reset_instructions_sent")

    token = @user.password_reset_token
    visit edit_password_url(token)
    fill_in "password", with: "newpassword123"
    fill_in "password_confirmation", with: "mismatch"
    click_button I18n.t("forms.buttons.reset_password")

    assert_text I18n.t("messages.errors.passwords_did_not_match")

    fill_in "password", with: "newpassword123"
    fill_in "password_confirmation", with: "newpassword123"
    click_button I18n.t("forms.buttons.reset_password")

    assert_current_path root_path
    assert_text I18n.t("messages.success.password_updated")
  end

  test "공개 정책 화면과 로그인 직접 접근을 확인한다" do
    visit terms_url
    assert_text I18n.t("pages.terms")
    assert_no_horizontal_overflow

    visit privacy_url
    assert_text I18n.t("pages.privacy")
    assert_no_horizontal_overflow

    visit new_session_url
    assert_field "email_address"
    assert_field "password"
  end
end
