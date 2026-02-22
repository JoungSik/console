require "test_helper"

class Todo::CompleteItemServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @list = Todo::List.create!(title: "테스트 리스트", user_id: @user.id)
  end

  test "일반 아이템 완료 시 completed가 true로 변경된다" do
    item = @list.items.create!(title: "일반 할일")

    Todo::CompleteItemService.new(item).call

    assert item.reload.completed?
  end

  test "일반 아이템 완료 시 새 아이템이 생성되지 않는다" do
    item = @list.items.create!(title: "일반 할일")

    assert_no_difference -> { @list.items.count } do
      Todo::CompleteItemService.new(item).call
    end
  end

  test "반복 아이템 완료 시 새 아이템이 생성된다" do
    item = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 1)
    )

    assert_difference -> { @list.items.count }, 1 do
      Todo::CompleteItemService.new(item).call
    end

    child = item.reload.recurrence_child
    assert_not_nil child
    assert_equal "반복 할일", child.title
    assert_equal "daily", child.recurrence
    assert_equal Date.new(2026, 3, 2), child.due_date
    assert_not child.completed?
    assert_equal item.id, child.recurrence_parent_id
  end

  test "반복 아이템 완료 시 URL과 종료일도 복사된다" do
    item = @list.items.create!(
      title: "반복 할일",
      url: "https://example.com",
      recurrence: "weekly",
      due_date: Date.new(2026, 3, 1),
      recurrence_ends_on: Date.new(2026, 12, 31)
    )

    Todo::CompleteItemService.new(item).call

    child = item.reload.recurrence_child
    assert_equal "https://example.com", child.url
    assert_equal "weekly", child.recurrence
    assert_equal Date.new(2026, 12, 31), child.recurrence_ends_on
  end

  test "종료일 초과 시 새 아이템이 생성되지 않는다" do
    item = @list.items.create!(
      title: "반복 할일",
      recurrence: "daily",
      due_date: Date.new(2026, 3, 10),
      recurrence_ends_on: Date.new(2026, 3, 10)
    )

    assert_no_difference -> { @list.items.count } do
      Todo::CompleteItemService.new(item).call
    end

    assert item.reload.completed?
  end
end
