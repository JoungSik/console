require "test_helper"

module FalseResultPlugin
  class DataCleaner
    def self.call(user_id:)
      false
    end
  end
end

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

  test "데이터 클리너가 false를 반환하면 false를 반환한다" do
    assert_not Console::PluginDataCleaner.clean_data_for(
      plugin_name: "false_result_plugin",
      user_id: users(:test_user).id
    )
  end

  test "플러그인 데이터베이스 트랜잭션을 연다" do
    post = Journal::Post.create!(body: "원복 대상", user_id: users(:test_user).id)

    assert_raises StandardError do
      Console::PluginDataCleaner.with_transaction(plugin_name: "posts") do
        post.destroy!
        raise StandardError
      end
    end

    assert Journal::Post.exists?(post.id)
  end

  test "트랜잭션 지원 여부를 확인한다" do
    assert Console::PluginDataCleaner.transaction_supported?(plugin_name: "posts")
    assert_not Console::PluginDataCleaner.transaction_supported?(plugin_name: "unknown_plugin")
  end
end
