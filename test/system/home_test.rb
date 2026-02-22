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

  test "대시보드에 플러그인 위젯이 표시된다" do
    sign_in_as @user

    assert_text "대시보드"
    assert_text "할 일 목록"
    assert_text "북마크"
    assert_text "정산"
  end

  test "위젯에서 전체보기 링크로 이동할 수 있다" do
    sign_in_as @user

    todo_widget = find("h2", text: "할 일 목록").ancestor(".shadow-sm")
    within(todo_widget) do
      click_link "전체보기"
    end

    assert_current_path "/todos"
  end
end
