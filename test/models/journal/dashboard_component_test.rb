require "test_helper"

class Journal::DashboardComponentTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @component = Journal::DashboardComponent.new(user_id: @user.id)
  end

  test "plugin_name은 포스트를 반환한다" do
    assert_equal "포스트", @component.plugin_name
  end

  test "partial_path를 반환한다" do
    assert_equal "journal/dashboard/widget", @component.partial_path
  end

  test "load_data는 self를 반환한다" do
    result = @component.load_data

    assert_same @component, result
  end

  test "데이터가 있을 때 올바른 통계를 반환한다" do
    Journal::Post.create!(body: "첫 번째 포스트", user_id: @user.id)
    Journal::Post.create!(body: "두 번째 포스트", user_id: @user.id)

    @component.load_data

    assert_equal 2, @component.posts_count
    assert_equal 2, @component.recent_posts.size
  end

  test "최근 포스트는 3개까지만 반환한다" do
    4.times do |index|
      Journal::Post.create!(body: "#{index}번째 포스트", user_id: @user.id)
    end

    @component.load_data

    assert_equal 4, @component.posts_count
    assert_equal 3, @component.recent_posts.size
  end

  test "다른 사용자의 데이터는 포함하지 않는다" do
    Journal::Post.create!(body: "다른 사용자 포스트", user_id: users(:other_user).id)

    @component.load_data

    assert_equal 0, @component.posts_count
    assert_empty @component.recent_posts
  end
end
