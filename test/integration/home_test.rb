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

  test "대시보드에 플러그인 위젯이 표시된다" do
    sign_in_as @user
    get root_url

    assert_response :success
    assert_select "h1", "대시보드"
    assert_select "h2", "할 일 목록"
    assert_select "h2", "북마크"
    assert_select "h2", "정산"
  end

  test "대시보드에 각 플러그인의 전체보기 링크가 있다" do
    sign_in_as @user
    get root_url

    assert_select "a[href='#{todo.root_path}']", "전체보기"
    assert_select "a[href='#{bookmark.root_path}']", "전체보기"
    assert_select "a[href='#{settlement.root_path}']", "전체보기"
  end
end
