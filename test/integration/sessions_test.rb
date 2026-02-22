require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
  end

  test "로그인 페이지에 접근할 수 있다" do
    get new_session_url
    assert_response :success
  end

  test "올바른 자격증명으로 로그인하면 root_path로 리다이렉트된다" do
    post session_url, params: { email_address: @user.email_address, password: "password123" }
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
  end

  test "잘못된 비밀번호로 로그인하면 실패한다" do
    post session_url, params: { email_address: @user.email_address, password: "wrong" }
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal I18n.t("messages.errors.invalid_credentials"), flash[:alert]
  end

  test "존재하지 않는 이메일로 로그인하면 실패한다" do
    post session_url, params: { email_address: "nobody@example.com", password: "password123" }
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal I18n.t("messages.errors.invalid_credentials"), flash[:alert]
  end

  test "로그아웃하면 new_session_path로 리다이렉트된다" do
    sign_in_as @user
    delete session_url
    assert_redirected_to new_session_path
  end

  test "비인증 상태에서 보호된 페이지에 접근하면 로그인 페이지로 리다이렉트된다" do
    get root_url
    assert_redirected_to new_session_path
  end
end
