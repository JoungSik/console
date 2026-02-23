require "test_helper"

class PluginDataDeletionJobTest < ActiveJob::TestCase
  test "30일 경과된 비활성 플러그인 데이터를 삭제한다" do
    user = users(:test_user)
    old_plugin = UserPlugin.create!(
      user: user, plugin_name: "bookmarks",
      enabled: false, disabled_at: 31.days.ago
    )

    assert_difference "UserPlugin.count", -1 do
      PluginDataDeletionJob.perform_now
    end

    assert_nil UserPlugin.find_by(id: old_plugin.id)
  end

  test "30일 미경과 비활성 플러그인은 삭제하지 않는다" do
    user = users(:test_user)
    UserPlugin.create!(user: user, plugin_name: "todos", enabled: false, disabled_at: 25.days.ago)

    assert_no_difference "UserPlugin.count" do
      PluginDataDeletionJob.perform_now
    end
  end
end
