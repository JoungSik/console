require "test_helper"

class Bookmark::DashboardComponentTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @component = Bookmark::DashboardComponent.new(user_id: @user.id)
  end

  test "plugin_name은 북마크를 반환한다" do
    assert_equal "북마크", @component.plugin_name
  end

  test "partial_path를 반환한다" do
    assert_equal "bookmark/dashboard/widget", @component.partial_path
  end

  test "load_data는 self를 반환한다" do
    result = @component.load_data

    assert_same @component, result
  end

  test "데이터가 있을 때 올바른 통계를 반환한다" do
    group = Bookmark::Group.create!(title: "테스트 그룹", user_id: @user.id)
    group.links.create!(title: "링크1", url: "https://example.com")
    group.links.create!(title: "링크2", url: "https://example.org")

    @component.load_data

    assert_equal 1, @component.groups_count
    assert_equal 2, @component.links_count
    assert_equal 1, @component.recent_groups.size
  end

  test "데이터가 없을 때 0을 반환한다" do
    @component.load_data

    assert_equal 0, @component.groups_count
    assert_equal 0, @component.links_count
    assert_empty @component.recent_groups
  end

  test "다른 사용자의 데이터는 포함하지 않는다" do
    Bookmark::Group.create!(title: "다른 사용자", user_id: @user.id + 999)

    @component.load_data

    assert_equal 0, @component.groups_count
  end
end
