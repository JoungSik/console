require "test_helper"

class Console::PluginDataCleanerTest < ActiveSupport::TestCase
  test "plural namespace 플러그인 데이터 클리너를 실행한다" do
    user = users(:test_user)
    Journal::Post.create!(body: "삭제 대상 포스트", user_id: user.id)

    assert_difference "Journal::Post.count", -1 do
      assert Console::PluginDataCleaner.clean_data_for(plugin_name: "posts", user_id: user.id)
    end
  end

  test "데이터 클리너가 없으면 false를 반환한다" do
    assert_not Console::PluginDataCleaner.clean_data_for(plugin_name: "unknown_plugin", user_id: users(:test_user).id)
  end
end
