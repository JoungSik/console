require "test_helper"

class Mypage::UsersTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  test "마이페이지를 조회할 수 있다" do
    get mypage_user_url
    assert_response :success
  end

  test "올바른 현재 비밀번호로 변경하면 재로그인이 필요하다" do
    patch mypage_user_url, params: {
      user: { current_password: "password123", password: "newpassword456", password_confirmation: "newpassword456" }
    }
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal I18n.t("settings.password.updated_please_login"), flash[:notice]
  end

  test "잘못된 현재 비밀번호로 변경하면 실패한다" do
    patch mypage_user_url, params: {
      user: { current_password: "wrong", password: "newpassword456", password_confirmation: "newpassword456" }
    }
    assert_redirected_to mypage_user_path
    follow_redirect!
    assert_equal I18n.t("settings.password.current_password_incorrect"), flash[:alert]
  end

  test "비밀번호 확인이 일치하지 않으면 실패한다" do
    patch mypage_user_url, params: {
      user: { current_password: "password123", password: "newpassword456", password_confirmation: "mismatch" }
    }
    assert_redirected_to mypage_user_path
  end
end
