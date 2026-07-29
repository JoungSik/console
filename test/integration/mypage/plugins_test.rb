require "test_helper"

class Mypage::PluginsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  test "플러그인 설정 페이지에 접근할 수 있다" do
    get mypage_plugins_url
    assert_response :success
    assert_select "h1", I18n.t("settings.plugins.title")
  end

  test "모든 등록된 플러그인이 표시된다" do
    get mypage_plugins_url
    assert_response :success

    PluginRegistry.all.each do |plugin|
      assert_select "h3", plugin.label
    end
  end

  test "플러그인을 비활성화할 수 있다" do
    assert_difference "UserPlugin.count", 1 do
      patch toggle_mypage_plugin_url("posts")
    end

    assert_response :see_other
    assert_redirected_to mypage_plugins_url

    user_plugin = @user.user_plugins.find_by(plugin_name: "posts")
    assert_not user_plugin.enabled?
    assert_not_nil user_plugin.disabled_at
  end

  test "비활성화된 플러그인을 다시 활성화할 수 있다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: 5.days.ago)

    patch toggle_mypage_plugin_url("todos")
    assert_response :see_other
    assert_redirected_to mypage_plugins_url

    user_plugin = @user.user_plugins.find_by(plugin_name: "todos")
    assert user_plugin.enabled?
    assert_nil user_plugin.disabled_at
  end

  test "존재하지 않는 플러그인은 토글할 수 없다" do
    patch toggle_mypage_plugin_url("nonexistent")
    assert_response :see_other
    assert_redirected_to mypage_plugins_url
  end

  test "Turbo Stream 토글은 플러그인 카드와 flash만 교체한다" do
    patch toggle_mypage_plugin_url("posts"), headers: turbo_stream_headers

    assert_response :success
    assert_select "turbo-stream[action='replace'][target='plugin_posts']"
    assert_select "turbo-stream[action='update'][target='flash']"
    assert_select "turbo-stream[target='plugin_posts']", text: /활성화/
  end

  test "Turbo Stream의 잘못된 플러그인은 flash만 422로 갱신한다" do
    patch toggle_mypage_plugin_url("nonexistent"), headers: turbo_stream_headers

    assert_response :unprocessable_entity
    assert_select "turbo-stream[action='update'][target='flash']"
    assert_select "turbo-stream[action='replace']", count: 0
  end
end
