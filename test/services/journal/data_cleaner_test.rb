require "test_helper"

class Journal::DataCleanerTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @other_user = users(:other_user)
  end

  test "대상 유저의 글을 모두 삭제한다" do
    Journal::Post.create!(body: "글 1", user_id: @user.id)
    Journal::Post.create!(body: "글 2", user_id: @user.id)

    Journal::DataCleaner.call(user_id: @user.id)

    assert_equal 0, Journal::Post.where(user_id: @user.id).count
  end

  test "타 유저의 글은 삭제하지 않는다" do
    Journal::Post.create!(body: "내 글", user_id: @user.id)
    Journal::Post.create!(body: "타인 글", user_id: @other_user.id)

    Journal::DataCleaner.call(user_id: @user.id)

    assert_equal 0, Journal::Post.where(user_id: @user.id).count
    assert_equal 1, Journal::Post.where(user_id: @other_user.id).count
  end

  test "삭제할 데이터가 없어도 예외 없이 동작한다" do
    assert_nothing_raised do
      Journal::DataCleaner.call(user_id: @user.id)
    end
  end
end
