require "application_system_test_case"

class TodoListsTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
    sign_in_as @user
  end


  test "할 일 목록을 생성할 수 있다" do
    visit todo.new_list_url
    fill_in "list[title]", with: "시스템 테스트 목록"
    click_button "할 일 목록 만들기"
    assert_text "시스템 테스트 목록"
    assert_text "할 일 목록이 생성되었습니다."
  end

  test "할 일 목록 인덱스를 조회할 수 있다" do
    Todo::List.create!(title: "조회용 목록", user_id: @user.id)
    visit todo.lists_url
    assert_text "조회용 목록"
  end

  test "할 일 목록을 수정할 수 있다" do
    list = Todo::List.create!(title: "수정 전", user_id: @user.id)
    visit todo.edit_list_url(list)
    fill_in "list[title]", with: "수정 후"
    click_button "할 일 목록 수정"
    assert_text "수정 후"
    assert_text "할 일 목록이 수정되었습니다."
  end

  test "할 일 목록을 삭제할 수 있다" do
    list = Todo::List.create!(title: "삭제 대상", user_id: @user.id)
    visit todo.list_url(list)
    accept_confirm do
      click_button "삭제"
    end
    assert_text "할 일 목록이 삭제되었습니다."
  end

  test "빈 상태 메시지가 표시된다" do
    visit todo.lists_url
    assert_text "할 일 목록이 없습니다"
  end
end
