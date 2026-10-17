require "test_helper"

class PluginPermissionTest < ActiveSupport::TestCase
  setup do
    @user = users(:other_user)
  end

  test "제한된 플러그인에 대한 권한을 부여할 수 있다" do
    assert PluginPermission.new(user: @user, plugin_name: "lotteries").valid?
  end

  test "제한되지 않았거나 등록되지 않은 플러그인에는 권한을 부여할 수 없다" do
    assert_not PluginPermission.new(user: @user, plugin_name: "todos").valid?
    assert_not PluginPermission.new(user: @user, plugin_name: "nonexistent").valid?
  end

  test "같은 사용자에게 같은 플러그인 권한을 중복 부여할 수 없다" do
    PluginPermission.create!(user: @user, plugin_name: "lotteries")

    assert_not PluginPermission.new(user: @user, plugin_name: "lotteries").valid?
  end
end
