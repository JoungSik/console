require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
  end

  test "인증된 사용자는 홈 화면에 접근할 수 있다" do
    sign_in_as @user
    get root_url
    assert_response :success
  end

  test "비인증 사용자는 로그인 페이지로 리다이렉트된다" do
    get root_url
    assert_redirected_to new_session_path
  end
end
