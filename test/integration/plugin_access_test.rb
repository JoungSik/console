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
    get "/posts"
    assert_response :success
  end

  test "비활성화된 posts 플러그인 경로에 접근하면 홈으로 리다이렉트된다" do
    UserPlugin.create!(user: @user, plugin_name: "posts", enabled: false, disabled_at: Time.current)

    get "/posts"
    assert_redirected_to "/"
  end

  test "비활성화된 inspirations 플러그인 경로에 접근하면 홈으로 리다이렉트된다" do
    UserPlugin.create!(user: @user, plugin_name: "inspirations", enabled: false, disabled_at: Time.current)

    get "/inspirations"
    assert_redirected_to "/"
  end

  test "권한이 없는 제한 플러그인 경로에 접근하면 홈으로 리다이렉트된다" do
    sign_in_as users(:other_user)

    get "/lotteries"
    assert_redirected_to "/"
  end

  test "권한이 없는 제한 플러그인은 메뉴와 대시보드에 표시되지 않는다" do
    sign_in_as users(:other_user)

    get root_url
    assert_response :success
    assert_select "a[href='/lotteries']", count: 0
    assert_select "h2", { text: "동행복권", count: 0 }
  end

  test "비활성화된 lotteries 플러그인 경로에 접근하면 홈으로 리다이렉트된다" do
    UserPlugin.create!(user: @user, plugin_name: "lotteries", enabled: false, disabled_at: Time.current)

    get "/lotteries"
    assert_redirected_to "/"
  end
end
