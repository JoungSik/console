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
    assert_select "h1", text: "포스트"
    assert_select "textarea[name='post[body]']"
  end

  test "포스트 상세에 접근할 수 있다" do
    get posts.post_url(@post)

    assert_response :success
    assert_select "p", text: @post.body
  end

  test "포스트 수정 폼에 접근할 수 있다" do
    get posts.edit_post_url(@post)

    assert_response :success
  end

  test "포스트를 생성할 수 있다" do
    assert_difference "Journal::Post.count", 1 do
      post posts.posts_url, params: { post: { body: "새 포스트" } }
    end

    assert_redirected_to posts.root_url
    assert_equal "새 포스트", Journal::Post.last.body
    assert_equal @user.id, Journal::Post.last.user_id
  end

  test "빈 본문으로 생성하면 422를 반환한다" do
    assert_no_difference "Journal::Post.count" do
      post posts.posts_url, params: { post: { body: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "280자 초과 본문으로 생성하면 422를 반환한다" do
    assert_no_difference "Journal::Post.count" do
      post posts.posts_url, params: { post: { body: "가" * 281 } }
    end

    assert_response :unprocessable_entity
  end

  test "포스트를 수정할 수 있다" do
    patch posts.post_url(@post), params: { post: { body: "수정된 포스트" } }

    assert_redirected_to posts.post_url(@post)
    assert_equal "수정된 포스트", @post.reload.body
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

    assert_redirected_to posts.root_url
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
