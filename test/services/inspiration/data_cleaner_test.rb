require "test_helper"

class Inspiration::DataCleanerTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @other_user = users(:other_user)
  end

  test "대상 유저의 아이디어와 진행 기록을 모두 삭제한다" do
    idea = Inspiration::Idea.create!(title: "내 아이디어", user_id: @user.id)
    idea.notes.create!(body: "기록")

    Inspiration::DataCleaner.call(user_id: @user.id)

    assert_equal 0, Inspiration::Idea.where(user_id: @user.id).count
    assert_equal 0, Inspiration::Note.count
  end

  test "타 유저의 아이디어는 삭제하지 않는다" do
    Inspiration::Idea.create!(title: "내 아이디어", user_id: @user.id)
    Inspiration::Idea.create!(title: "타인 아이디어", user_id: @other_user.id)

    Inspiration::DataCleaner.call(user_id: @user.id)

    assert_equal 1, Inspiration::Idea.where(user_id: @other_user.id).count
  end
end
