require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
  end

  test "plugin_enabled?는 레코드가 없으면 true를 반환한다" do
    assert @user.plugin_enabled?(:bookmarks)
  end

  test "plugin_enabled?는 비활성화된 플러그인에 false를 반환한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    assert_not @user.plugin_enabled?(:todos)
  end

  test "plugin_enabled?는 심볼과 문자열 모두 지원한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    assert_not @user.plugin_enabled?("todos")
    assert_not @user.plugin_enabled?(:todos)
  end

  test "enabled_plugins는 비활성 플러그인을 제외한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    enabled = @user.enabled_plugins
    enabled_names = enabled.map(&:name)

    assert_not_includes enabled_names, :todos
    assert_includes enabled_names, :bookmarks
  end

  test "approaching_deletion_plugins는 삭제 임박 플러그인을 반환한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: 25.days.ago)

    approaching = @user.approaching_deletion_plugins
    assert approaching.any? { |item| item[:plugin].name == :todos }
  end
end
