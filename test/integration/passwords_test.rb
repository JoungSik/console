require "test_helper"

class PasswordsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
  end

  test "비밀번호 찾기 페이지에 접근할 수 있다" do
    get new_password_url
    assert_response :success
  end

  test "로그인 페이지에 비밀번호 찾기 링크가 표시된다" do
    get new_session_url
    assert_response :success
    assert_select "a[href=?]", new_password_path, text: I18n.t("forms.buttons.forgot_password")
  end

  test "존재하는 이메일로 재설정을 요청하면 메일이 발송된다" do
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ] do
      post passwords_url, params: { email_address: @user.email_address }
    end
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal I18n.t("messages.success.password_reset_instructions_sent"), flash[:notice]
  end

  test "존재하지 않는 이메일로도 동일하게 리다이렉트된다" do
    post passwords_url, params: { email_address: "nobody@example.com" }
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal I18n.t("messages.success.password_reset_instructions_sent"), flash[:notice]
  end

  test "유효한 토큰으로 비밀번호 재설정 페이지에 접근할 수 있다" do
    token = @user.password_reset_token
    get edit_password_url(token)
    assert_response :success
  end

  test "유효하지 않은 토큰으로 접근하면 new_password_path로 리다이렉트된다" do
    get edit_password_url("invalid-token")
    assert_redirected_to new_password_path
    follow_redirect!
    assert_equal I18n.t("messages.errors.password_reset_link_invalid"), flash[:alert]
  end

  test "새 비밀번호를 성공적으로 저장하면 자동 로그인된다" do
    token = @user.password_reset_token
    patch password_url(token), params: { password: "newpassword123", password_confirmation: "newpassword123" }
    assert_redirected_to root_url
    assert cookies[:session_id].present?, "세션 쿠키가 설정되어야 합니다"
    follow_redirect!
    assert_equal I18n.t("messages.success.password_updated"), flash[:notice]
  end

  test "비밀번호 확인이 일치하지 않으면 실패한다" do
    token = @user.password_reset_token
    patch password_url(token), params: { password: "newpassword123", password_confirmation: "mismatch" }
    assert_redirected_to edit_password_path(token)
    follow_redirect!
    assert_equal I18n.t("messages.errors.passwords_did_not_match"), flash[:alert]
  end

  test "Rate Limiting 초과 시 경고 메시지가 표시된다" do
    6.times do
      post passwords_url, params: { email_address: @user.email_address }
    end
    assert_redirected_to new_password_url
    follow_redirect!
    assert_equal I18n.t("messages.errors.rate_limit_exceeded"), flash[:alert]
  end

  test "비밀번호 재설정 메일에 만료 안내가 포함된다" do
    mail = PasswordsMailer.reset(@user)
    assert_includes mail.html_part.body.to_s, I18n.t("emails.password_reset.expire_notice")
    assert_includes mail.html_part.body.to_s, I18n.t("emails.password_reset.body")
    assert_includes mail.html_part.body.to_s, I18n.t("emails.password_reset.reset_button")
    assert_includes mail.text_part.body.to_s, I18n.t("emails.password_reset.expire_notice")
  end
end
