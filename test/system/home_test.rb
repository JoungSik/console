require "application_system_test_case"

class HomeSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
  end

  test "로그인 후 홈 화면이 표시된다" do
    sign_in_as @user
    assert_current_path root_path
  end

  test "비인증 상태에서 접근하면 로그인 페이지로 이동한다" do
    visit root_url
    assert_current_path new_session_path
  end
end
