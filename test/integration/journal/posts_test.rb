require "test_helper"

class Journal::PostsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @post = Journal::Post.create!(body: "테스트 포스트", user_id: @user.id)
  end

  test "포스트 인덱스에 접근할 수 있다" do
    get posts.root_url

    assert_response :success
    assert_select "title", text: "포스트"
    assert_select "h1", text: "포스트"
    assert_select "textarea[name='post[body]']"
  end

  test "포스트 상세에 접근할 수 있다" do
    get posts.post_url(@post)

    assert_response :success
    assert_select "p", text: @post.body
  end

  test "Native 포스트 화면은 웹 제목과 뒤로가기를 숨긴다" do
    native_headers = { "User-Agent" => "Console Hotwire Native iOS" }

    get posts.root_url, headers: native_headers
    assert_response :success
    assert_select "link[rel='stylesheet'][href*='hotwire_native']"
    assert_select "[data-native-page-title]", text: "포스트"

    get posts.post_url(@post), headers: native_headers
    assert_response :success
    assert_select "[data-native-page-navigation]", text: "포스트"

    get posts.edit_post_url(@post), headers: native_headers
    assert_response :success
    assert_select "[data-native-page-title]", text: "포스트 수정"
    assert_select "[data-native-page-navigation]", text: "포스트"
  end

  test "포스트 수정 폼에 접근할 수 있다" do
    get posts.edit_post_url(@post)

    assert_response :success
  end

  test "포스트를 생성할 수 있다" do
    assert_difference "Journal::Post.count", 1 do
      post posts.posts_url, params: { post: { body: "새 포스트" } }
    end

    assert_response :see_other
    assert_redirected_to posts.root_url
    assert_equal "새 포스트", Journal::Post.last.body
    assert_equal @user.id, Journal::Post.last.user_id
  end

  test "Turbo Stream으로 포스트를 생성하면 작성 영역과 목록과 flash를 갱신한다" do
    assert_difference "Journal::Post.count", 1 do
      post posts.posts_url,
        params: { post: { body: "Stream 포스트" } },
        headers: turbo_stream_headers
    end

    assert_response :success
    assert_select "turbo-stream[action='update'][target='post_composer']"
    assert_select "turbo-stream[action='update'][target='posts']"
    assert_select "turbo-stream[action='update'][target='flash']"
    assert_select "turbo-stream[target='posts']", text: /Stream 포스트/
  end

  test "빈 본문으로 생성하면 422를 반환한다" do
    assert_no_difference "Journal::Post.count" do
      post posts.posts_url, params: { post: { body: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "Turbo Stream 생성 검증 오류는 입력값이 있는 작성 영역만 갱신한다" do
    post posts.posts_url,
      params: { post: { body: "" } },
      headers: turbo_stream_headers

    assert_response :unprocessable_entity
    assert_select "turbo-stream[action='update'][target='post_composer']"
    assert_select "turbo-stream[target='posts']", count: 0
    assert_select "textarea[name='post[body]']"
  end

  test "280자 초과 본문으로 생성하면 422를 반환한다" do
    assert_no_difference "Journal::Post.count" do
      post posts.posts_url, params: { post: { body: "가" * 281 } }
    end

    assert_response :unprocessable_entity
  end

  test "포스트를 수정할 수 있다" do
    patch posts.post_url(@post), params: { post: { body: "수정된 포스트" } }

    assert_response :see_other
    assert_redirected_to posts.post_url(@post)
    assert_equal "수정된 포스트", @post.reload.body
  end

  test "Native Turbo Stream으로 포스트를 수정하면 현재 화면 새로고침을 요청한다" do
    patch posts.post_url(@post),
      params: { post: { body: "Native 수정 포스트" } },
      headers: turbo_stream_headers.merge("User-Agent" => "Console Hotwire Native iOS")

    assert_redirected_to Rails.application.routes.url_helpers.turbo_refresh_historical_location_path(
      notice: "포스트가 수정되었습니다."
    )
    assert_equal "Native 수정 포스트", @post.reload.body
  end

  test "빈 본문으로 수정하면 422를 반환한다" do
    patch posts.post_url(@post), params: { post: { body: "" } }

    assert_response :unprocessable_entity
    assert_equal "테스트 포스트", @post.reload.body
  end

  test "포스트를 삭제할 수 있다" do
    assert_difference "Journal::Post.count", -1 do
      delete posts.post_url(@post)
    end

    assert_response :see_other
    assert_redirected_to posts.root_url
  end

  test "인덱스의 Turbo Stream 삭제는 목록과 flash를 갱신한다" do
    assert_difference "Journal::Post.count", -1 do
      delete posts.post_url(@post),
        params: { source: "index" },
        headers: turbo_stream_headers
    end

    assert_response :success
    assert_select "turbo-stream[action='update'][target='posts']"
    assert_select "turbo-stream[action='update'][target='flash']"
    assert_select "turbo-stream[target='posts']", text: /포스트가 없습니다/
  end

  test "다른 사용자의 포스트 상세에 접근하면 404를 반환한다" do
    other_post = Journal::Post.create!(body: "다른 사용자 포스트", user_id: users(:other_user).id)

    get posts.post_url(other_post)

    assert_response :not_found
  end

  test "다른 사용자의 포스트 수정에 접근하면 404를 반환한다" do
    other_post = Journal::Post.create!(body: "다른 사용자 포스트", user_id: users(:other_user).id)

    patch posts.post_url(other_post), params: { post: { body: "변경 시도" } }

    assert_response :not_found
    assert_equal "다른 사용자 포스트", other_post.reload.body
  end

  test "다른 사용자의 포스트 삭제에 접근하면 404를 반환한다" do
    other_post = Journal::Post.create!(body: "다른 사용자 포스트", user_id: users(:other_user).id)

    assert_no_difference "Journal::Post.count" do
      delete posts.post_url(other_post)
    end

    assert_response :not_found
  end
end
