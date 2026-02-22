require "test_helper"

class PasswordsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
  end

  test "비밀번호 찾기 페이지에 접근할 수 있다" do
    get new_password_url
    assert_response :success
  end

  test "존재하는 이메일로 재설정을 요청하면 메일이 발송된다" do
    assert_enqueued_email_with PasswordsMailer, :reset, args: [@user] do
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

  test "새 비밀번호를 성공적으로 저장할 수 있다" do
    token = @user.password_reset_token
    patch password_url(token), params: { password: "newpassword123", password_confirmation: "newpassword123" }
    assert_redirected_to new_session_path
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
end
