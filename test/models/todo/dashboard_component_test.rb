require "test_helper"

class Todo::DashboardComponentTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @component = Todo::DashboardComponent.new(user_id: @user.id)
  end

  test "plugin_name은 할 일 목록을 반환한다" do
    assert_equal "할 일 목록", @component.plugin_name
  end

  test "partial_path를 반환한다" do
    assert_equal "todo/dashboard/widget", @component.partial_path
  end

  test "load_data는 self를 반환한다" do
    result = @component.load_data

    assert_same @component, result
  end

  test "데이터가 있을 때 올바른 통계를 반환한다" do
    list = Todo::List.create!(title: "테스트", user_id: @user.id)
    list.items.create!(title: "미완료1", completed: false)
    list.items.create!(title: "미완료2", completed: false, due_date: Date.current - 1.day)
    list.items.create!(title: "완료", completed: true)

    @component.load_data

    assert_equal 2, @component.incomplete_count
    assert_equal 1, @component.overdue_count
  end

  test "데이터가 없을 때 0을 반환한다" do
    @component.load_data

    assert_equal 0, @component.incomplete_count
    assert_equal 0, @component.overdue_count
    assert_empty @component.today_items
  end

  test "다른 사용자의 데이터는 포함하지 않는다" do
    other_list = Todo::List.create!(title: "다른 사용자", user_id: @user.id + 999)
    other_list.items.create!(title: "다른 사용자 항목", completed: false)

    @component.load_data

    assert_equal 0, @component.incomplete_count
  end

  test "아카이브된 목록은 제외한다" do
    archived_list = Todo::List.create!(title: "아카이브", user_id: @user.id, archived_at: Time.current)
    archived_list.items.create!(title: "아카이브 항목", completed: false)

    @component.load_data

    assert_equal 0, @component.incomplete_count
  end

  test "오늘 마감 항목을 표시한다" do
    list = Todo::List.create!(title: "테스트", user_id: @user.id)
    list.items.create!(title: "오늘 할 일", completed: false, due_date: Date.current)

    @component.load_data

    assert_equal 1, @component.today_items.size
    assert_equal "오늘 할 일", @component.today_items.first.title
  end

  test "기한 초과 항목을 표시한다" do
    list = Todo::List.create!(title: "테스트", user_id: @user.id)
    list.items.create!(title: "기한 초과", completed: false, due_date: Date.current - 3.days)

    @component.load_data

    assert_equal 1, @component.today_items.size
    assert_equal "기한 초과", @component.today_items.first.title
  end

  test "기한 초과 항목이 오늘 마감보다 먼저 표시된다" do
    list = Todo::List.create!(title: "테스트", user_id: @user.id)
    list.items.create!(title: "오늘 마감", completed: false, due_date: Date.current)
    list.items.create!(title: "기한 초과", completed: false, due_date: Date.current - 2.days)

    @component.load_data

    assert_equal "기한 초과", @component.today_items.first.title
    assert_equal "오늘 마감", @component.today_items.last.title
  end

  test "미래 마감 항목은 표시하지 않는다" do
    list = Todo::List.create!(title: "테스트", user_id: @user.id)
    list.items.create!(title: "미래 항목", completed: false, due_date: Date.current + 3.days)

    @component.load_data

    assert_empty @component.today_items
  end

  test "기한이 없는 미완료 항목은 표시하지 않는다" do
    list = Todo::List.create!(title: "테스트", user_id: @user.id)
    list.items.create!(title: "기한 없음", completed: false)

    @component.load_data

    assert_empty @component.today_items
  end
end
