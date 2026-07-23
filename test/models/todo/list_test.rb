require "test_helper"

class Todo::ListTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @other_user = users(:other_user)
  end

  test "active 스코프는 보관되지 않은 리스트만 반환한다" do
    active = Todo::List.create!(title: "활성", user_id: @user.id)
    archived = Todo::List.create!(title: "보관", user_id: @user.id, archived_at: Time.current)

    result = Todo::List.by_user(@user.id).active
    assert_includes result, active
    assert_not_includes result, archived
  end

  test "archived 스코프는 보관된 리스트만 반환한다" do
    active = Todo::List.create!(title: "활성", user_id: @user.id)
    archived = Todo::List.create!(title: "보관", user_id: @user.id, archived_at: Time.current)

    result = Todo::List.by_user(@user.id).archived
    assert_includes result, archived
    assert_not_includes result, active
  end

  test "by_user 스코프는 해당 유저의 리스트만 반환한다" do
    mine = Todo::List.create!(title: "내 것", user_id: @user.id)
    theirs = Todo::List.create!(title: "타인 것", user_id: @other_user.id)

    result = Todo::List.by_user(@user.id)
    assert_includes result, mine
    assert_not_includes result, theirs
  end

  test "archived_at이 있으면 archived?는 true" do
    list = Todo::List.new(title: "리스트", user_id: @user.id, archived_at: Time.current)
    assert list.archived?
  end

  test "archived_at이 없으면 archived?는 false" do
    list = Todo::List.new(title: "리스트", user_id: @user.id)
    assert_not list.archived?
  end

  test "archive!는 archived_at을 설정한다" do
    list = Todo::List.create!(title: "리스트", user_id: @user.id)
    assert_not list.archived?

    list.archive!

    assert list.archived?
    assert_not_nil list.archived_at
  end

  test "unarchive!는 archived_at을 해제한다" do
    list = Todo::List.create!(title: "리스트", user_id: @user.id, archived_at: Time.current)
    assert list.archived?

    list.unarchive!

    assert_not list.archived?
    assert_nil list.archived_at
  end

  test "sorted_items는 미완료를 먼저, 마감일 오름차순으로 정렬한다" do
    list = Todo::List.create!(title: "리스트", user_id: @user.id)
    later = list.items.create!(title: "미완료 늦은 마감", completed: false, due_date: Date.new(2026, 3, 5))
    earlier = list.items.create!(title: "미완료 이른 마감", completed: false, due_date: Date.new(2026, 3, 1))
    done = list.items.create!(title: "완료", completed: true, due_date: Date.new(2026, 3, 1))

    assert_equal [ earlier.id, later.id, done.id ], list.sorted_items.map(&:id)
  end

  test "sorted_items는 동일 조건에서 생성일 최신순으로 정렬한다" do
    list = Todo::List.create!(title: "리스트", user_id: @user.id)
    older = list.items.create!(title: "먼저 생성", completed: false, due_date: Date.new(2026, 3, 1), created_at: 2.days.ago)
    newer = list.items.create!(title: "나중 생성", completed: false, due_date: Date.new(2026, 3, 1), created_at: 1.day.ago)

    assert_equal [ newer.id, older.id ], list.sorted_items.map(&:id)
  end

  test "displayed_items는 상위 5개만 반환한다" do
    list = Todo::List.create!(title: "리스트", user_id: @user.id)
    6.times do |i|
      list.items.create!(title: "할일 #{i}", due_date: Date.new(2026, 3, i + 1))
    end

    assert_equal 6, list.sorted_items.count
    assert_equal 5, list.displayed_items.count
  end

  test "title이 없으면 유효하지 않다" do
    list = Todo::List.new(user_id: @user.id)
    assert_not list.valid?
    assert list.errors[:title].any?
  end

  test "title이 100자면 유효하다" do
    list = Todo::List.new(title: "가" * 100, user_id: @user.id)
    assert list.valid?
  end

  test "title이 100자를 초과하면 유효하지 않다" do
    list = Todo::List.new(title: "가" * 101, user_id: @user.id)
    assert_not list.valid?
  end
end
