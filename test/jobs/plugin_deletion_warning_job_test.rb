require "test_helper"

class PluginDeletionWarningJobTest < ActiveJob::TestCase
  test "삭제 임박 플러그인 사용자에게 알림을 발송한다" do
    user = users(:test_user)
    UserPlugin.create!(user: user, plugin_name: "todos", enabled: false, disabled_at: 25.days.ago)

    assert_nothing_raised do
      PluginDeletionWarningJob.perform_now
    end
  end
end
