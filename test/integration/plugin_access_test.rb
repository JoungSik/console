require "test_helper"

class PluginAccessTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  test "비활성화된 플러그인 경로에 접근하면 홈으로 리다이렉트된다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    get "/todos"
    assert_redirected_to "/"
  end

  test "활성화된 플러그인 경로에는 정상 접근할 수 있다" do
    get "/bookmarks"
    assert_response :success
  end
end
