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

    assert_equal 1, @component.lists_count
    assert_equal 2, @component.incomplete_count
    assert_equal 1, @component.overdue_count
    assert_equal 2, @component.recent_items.size
  end

  test "데이터가 없을 때 0을 반환한다" do
    @component.load_data

    assert_equal 0, @component.lists_count
    assert_equal 0, @component.incomplete_count
    assert_equal 0, @component.overdue_count
    assert_empty @component.recent_items
  end

  test "다른 사용자의 데이터는 포함하지 않는다" do
    Todo::List.create!(title: "다른 사용자", user_id: @user.id + 999)

    @component.load_data

    assert_equal 0, @component.lists_count
  end

  test "아카이브된 목록은 제외한다" do
    Todo::List.create!(title: "아카이브", user_id: @user.id, archived_at: Time.current)

    @component.load_data

    assert_equal 0, @component.lists_count
  end
end
