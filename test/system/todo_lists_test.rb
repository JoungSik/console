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
      click_link "삭제"
    end
    assert_text "할 일 목록이 삭제되었습니다."
  end

  test "빈 상태 메시지가 표시된다" do
    visit todo.lists_url
    assert_text "할 일 목록이 없습니다"
  end

  test "제목 검증 오류는 입력 화면과 422 내용을 유지한다" do
    visit todo.new_list_url
    click_button "할 일 목록 만들기"

    assert_text "개의 오류가 있습니다"
    assert_current_path todo.new_list_path
  end

  test "중첩 반복 항목을 추가하고 삭제할 수 있다" do
    visit todo.new_list_url
    fill_in "list[title]", with: "중첩 항목 목록"
    click_link "새 할 일 만들기"

    within(".item-fields") do
      fill_in placeholder: "할 일 제목을 입력하세요", with: "매일 반복 항목"
      find("input[type='date']", match: :first).set(Date.current)
      select "매일", from: "반복"
      assert_selector "[data-recurrence-target='endsOnField']", visible: true
    end
    click_button "할 일 목록 만들기"

    assert_text "할 일 목록이 생성되었습니다."
    list = Todo::List.find_by!(title: "중첩 항목 목록")
    assert_current_path todo.list_path(list)
    assert_text "매일 반복 항목"
    assert_selector "[title='반복: 매일']"

    click_link "수정"
    within(".item-fields") { click_link "할 일 삭제" }
    click_button "할 일 목록 수정"

    assert_current_path todo.list_path(list)
    assert_text "아직 할 일이 없습니다."
  end

  test "목록을 보관하고 복원할 수 있다" do
    list = Todo::List.create!(title: "보관 전환 목록", user_id: @user.id)
    visit todo.edit_list_url(list)

    check "보관"
    click_button "할 일 목록 수정"
    assert_text "보관됨"
    assert list.reload.archived?

    click_link "수정"
    uncheck "보관"
    click_button "할 일 목록 수정"
    assert_no_text "보관됨"
    assert_not list.reload.archived?
  end
end
