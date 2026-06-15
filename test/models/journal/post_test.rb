require "test_helper"

class Journal::PostTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @post = Journal::Post.new(body: "오늘의 기록", user_id: @user.id)
  end

  test "유효한 포스트가 저장된다" do
    assert @post.valid?
  end

  test "본문은 필수이다" do
    @post.body = ""

    assert_not @post.valid?
    assert @post.errors[:body].any?
  end

  test "본문은 280자를 넘을 수 없다" do
    @post.body = "가" * 281

    assert_not @post.valid?
    assert @post.errors[:body].any?
  end

  test "user_id는 필수이다" do
    @post.user_id = nil

    assert_not @post.valid?
    assert @post.errors[:user_id].any?
  end

  test "by_user 스코프는 사용자별로 필터링한다" do
    own_post = Journal::Post.create!(body: "내 포스트", user_id: @user.id)
    other_post = Journal::Post.create!(body: "다른 사용자 포스트", user_id: users(:other_user).id)

    assert_includes Journal::Post.by_user(@user.id), own_post
    assert_not_includes Journal::Post.by_user(@user.id), other_post
  end

  test "recent 스코프는 최신순으로 정렬한다" do
    old_post = Journal::Post.create!(body: "오래된 포스트", user_id: @user.id, created_at: 2.days.ago)
    recent_post = Journal::Post.create!(body: "최근 포스트", user_id: @user.id, created_at: 1.day.ago)

    assert_equal [ recent_post, old_post ], Journal::Post.by_user(@user.id).recent.to_a
  end
end
