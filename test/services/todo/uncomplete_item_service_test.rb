require "test_helper"

class Todo::UncompleteItemServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @list = Todo::List.create!(title: "테스트 리스트", user_id: @user.id)
  end

  test "아이템 완료 취소 시 completed가 false로 변경된다" do
    item = @list.items.create!(title: "할일", completed: true)

    Todo::UncompleteItemService.new(item).call

    assert_not item.reload.completed?
  end

  test "완료 취소 시 자식 아이템이 삭제된다" do
    parent = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 1),
      completed: true
    )
    child = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 2),
      recurrence_parent_id: parent.id,
      completed: false
    )

    assert_difference -> { @list.items.count }, -1 do
      Todo::UncompleteItemService.new(parent).call
    end

    assert_not parent.reload.completed?
    assert_raises(ActiveRecord::RecordNotFound) { child.reload }
  end

  test "완료된 자식 아이템도 삭제된다" do
    parent = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 1),
      completed: true
    )
    child = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 2),
      recurrence_parent_id: parent.id,
      completed: true
    )

    assert_difference -> { @list.items.count }, -1 do
      Todo::UncompleteItemService.new(parent).call
    end

    assert_not parent.reload.completed?
    assert_raises(ActiveRecord::RecordNotFound) { child.reload }
  end

  test "하위 체인 전체가 연쇄 삭제된다" do
    a = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 1),
      completed: true
    )
    b = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 2),
      recurrence_parent_id: a.id,
      completed: true
    )
    c = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 3),
      recurrence_parent_id: b.id,
      completed: false
    )

    assert_difference -> { @list.items.count }, -2 do
      Todo::UncompleteItemService.new(a).call
    end

    assert_not a.reload.completed?
    assert_raises(ActiveRecord::RecordNotFound) { b.reload }
    assert_raises(ActiveRecord::RecordNotFound) { c.reload }
  end

  test "자식 아이템이 없는 경우에도 정상 동작한다" do
    item = @list.items.create!(title: "할일", completed: true)

    assert_nothing_raised do
      Todo::UncompleteItemService.new(item).call
    end

    assert_not item.reload.completed?
  end
end
