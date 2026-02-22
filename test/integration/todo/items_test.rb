require "test_helper"

class Todo::ItemsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @list = Todo::List.create!(title: "테스트 목록", user_id: @user.id)
    @item = @list.items.create!(title: "테스트 할일", completed: false)
  end

  teardown do
    Todo::List.where(user_id: @user.id).destroy_all
  end

  test "항목을 완료 상태로 토글할 수 있다" do
    patch todo.list_item_url(@list, @item), params: { item: { completed: true } }
    assert_redirected_to todo.list_url(@list)
    assert @item.reload.completed?
  end

  test "항목을 미완료 상태로 토글할 수 있다" do
    @item.update!(completed: true)
    patch todo.list_item_url(@list, @item), params: { item: { completed: false } }
    assert_redirected_to todo.list_url(@list)
    assert_not @item.reload.completed?
  end

  test "항목을 삭제할 수 있다" do
    assert_difference "Todo::Item.count", -1 do
      delete todo.list_item_url(@list, @item)
    end
    assert_redirected_to todo.list_url(@list)
  end

  # === 반복 기능 테스트 ===

  test "반복 항목 완료 시 다음 반복 아이템이 생성된다" do
    recurring_item = @list.items.create!(
      title: "반복 할일", recurrence: "daily", due_date: Date.current, completed: false
    )

    assert_difference "Todo::Item.count", 1 do
      patch todo.list_item_url(@list, recurring_item), params: { item: { completed: true } }
    end
    assert_redirected_to todo.list_url(@list)
    assert recurring_item.reload.completed?

    # 새로 생성된 다음 반복 아이템 확인
    child = recurring_item.recurrence_child
    assert_not_nil child
    assert_equal "반복 할일", child.title
    assert_equal Date.current + 1.day, child.due_date
    assert_equal "daily", child.recurrence
    assert_not child.completed?
  end

  test "일반 항목 완료 시 다음 반복 아이템이 생성되지 않는다" do
    assert_no_difference "Todo::Item.count" do
      patch todo.list_item_url(@list, @item), params: { item: { completed: true } }
    end
  end

  test "반복 항목 완료 취소 시 자식 아이템이 삭제된다" do
    recurring_item = @list.items.create!(
      title: "반복 할일", recurrence: "weekly", due_date: Date.current, completed: false
    )

    # 먼저 완료 처리
    patch todo.list_item_url(@list, recurring_item), params: { item: { completed: true } }
    child = recurring_item.reload.recurrence_child
    assert_not_nil child

    # 완료 취소 시 자식 삭제
    assert_difference "Todo::Item.count", -1 do
      patch todo.list_item_url(@list, recurring_item), params: { item: { completed: false } }
    end
    assert_not recurring_item.reload.completed?
    assert_nil recurring_item.recurrence_child
  end

  test "종료일이 지난 반복 항목 완료 시 다음 반복이 생성되지 않는다" do
    recurring_item = @list.items.create!(
      title: "반복 할일", recurrence: "daily", due_date: Date.current,
      recurrence_ends_on: Date.current, completed: false
    )

    assert_no_difference "Todo::Item.count" do
      patch todo.list_item_url(@list, recurring_item), params: { item: { completed: true } }
    end
    assert recurring_item.reload.completed?
  end
end
