require "test_helper"

class Settlement::DashboardComponentTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @component = Settlement::DashboardComponent.new(user_id: @user.id)
  end

  test "plugin_name은 정산을 반환한다" do
    assert_equal "정산", @component.plugin_name
  end

  test "partial_path를 반환한다" do
    assert_equal "settlement/dashboard/widget", @component.partial_path
  end

  test "load_data는 self를 반환한다" do
    result = @component.load_data

    assert_same @component, result
  end

  test "데이터가 있을 때 올바른 통계를 반환한다" do
    gathering = Settlement::Gathering.create!(title: "모임", user_id: @user.id)
    gathering.members.create!(name: "멤버1")
    gathering.members.create!(name: "멤버2")

    @component.load_data

    assert_equal 1, @component.gatherings_count
    assert_equal 1, @component.recent_gatherings.size
    assert_equal 2, @component.recent_gatherings.first.members.size
  end

  test "데이터가 없을 때 0을 반환한다" do
    @component.load_data

    assert_equal 0, @component.gatherings_count
    assert_empty @component.recent_gatherings
  end

  test "다른 사용자의 데이터는 포함하지 않는다" do
    Settlement::Gathering.create!(title: "다른 사용자", user_id: @user.id + 999)

    @component.load_data

    assert_equal 0, @component.gatherings_count
  end
end
