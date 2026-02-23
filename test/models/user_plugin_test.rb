require "test_helper"

class UserPluginTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
  end

  test "유효한 user_plugin을 생성할 수 있다" do
    user_plugin = UserPlugin.new(user: @user, plugin_name: "bookmarks", enabled: true)
    assert user_plugin.valid?
  end

  test "plugin_name은 필수이다" do
    user_plugin = UserPlugin.new(user: @user, plugin_name: nil)
    assert_not user_plugin.valid?
    assert user_plugin.errors[:plugin_name].present?
  end

  test "같은 사용자에게 같은 plugin_name은 중복 불가" do
    UserPlugin.create!(user: @user, plugin_name: "bookmarks")
    duplicate = UserPlugin.new(user: @user, plugin_name: "bookmarks")
    assert_not duplicate.valid?
  end

  test "disable!은 enabled를 false로 설정하고 disabled_at을 기록한다" do
    user_plugin = UserPlugin.create!(user: @user, plugin_name: "bookmarks")
    user_plugin.disable!

    assert_not user_plugin.enabled?
    assert_not_nil user_plugin.disabled_at
  end

  test "enable!은 enabled를 true로 설정하고 disabled_at을 nil로 만든다" do
    user_plugin = UserPlugin.create!(
      user: @user, plugin_name: "todos",
      enabled: false, disabled_at: 25.days.ago
    )
    user_plugin.enable!

    assert user_plugin.enabled?
    assert_nil user_plugin.disabled_at
  end

  test "days_until_deletion은 남은 일수를 반환한다" do
    user_plugin = UserPlugin.create!(
      user: @user, plugin_name: "todos",
      enabled: false, disabled_at: 25.days.ago
    )
    days = user_plugin.days_until_deletion

    assert_in_delta 5, days, 1
  end

  test "days_until_deletion은 disabled_at이 nil이면 nil을 반환한다" do
    user_plugin = UserPlugin.new(user: @user, plugin_name: "bookmarks", enabled: true)
    assert_nil user_plugin.days_until_deletion
  end

  test "enabled scope는 활성화된 플러그인만 반환한다" do
    UserPlugin.create!(user: @user, plugin_name: "bookmarks", enabled: true)

    enabled = UserPlugin.enabled
    assert enabled.all?(&:enabled?)
  end

  test "disabled scope는 비활성화된 플러그인만 반환한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: 5.days.ago)

    disabled = UserPlugin.disabled
    assert disabled.any?
    assert disabled.none?(&:enabled?)
  end

  test "pending_deletion scope는 30일 경과된 비활성 플러그인을 반환한다" do
    old_plugin = UserPlugin.create!(
      user: @user, plugin_name: "bookmarks",
      enabled: false, disabled_at: 31.days.ago
    )
    recent_plugin = UserPlugin.create!(
      user: @user, plugin_name: "todos",
      enabled: false, disabled_at: 25.days.ago
    )

    assert_includes UserPlugin.pending_deletion, old_plugin
    assert_not_includes UserPlugin.pending_deletion, recent_plugin
  end

  test "approaching_deletion scope는 23~30일 범위의 비활성 플러그인을 반환한다" do
    approaching_plugin = UserPlugin.create!(
      user: @user, plugin_name: "todos",
      enabled: false, disabled_at: 25.days.ago
    )

    assert_includes UserPlugin.approaching_deletion, approaching_plugin
  end
end
