require "test_helper"

class Todo::DataCleanerTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @other_user = users(:other_user)
  end

  test "대상 유저의 리스트를 모두 삭제한다" do
    Todo::List.create!(title: "리스트 A", user_id: @user.id)
    Todo::List.create!(title: "리스트 B", user_id: @user.id)

    Todo::DataCleaner.call(user_id: @user.id)

    assert_equal 0, Todo::List.by_user(@user.id).count
  end

  test "타 유저의 리스트는 삭제하지 않는다" do
    Todo::List.create!(title: "내 리스트", user_id: @user.id)
    Todo::List.create!(title: "타인 리스트", user_id: @other_user.id)

    Todo::DataCleaner.call(user_id: @user.id)

    assert_equal 0, Todo::List.by_user(@user.id).count
    assert_equal 1, Todo::List.by_user(@other_user.id).count
  end

  test "보관된 리스트도 삭제한다" do
    list = Todo::List.create!(title: "보관 리스트", user_id: @user.id)
    list.archive!

    Todo::DataCleaner.call(user_id: @user.id)

    assert_equal 0, Todo::List.by_user(@user.id).count
  end

  test "리스트의 하위 아이템도 함께 삭제한다" do
    list = Todo::List.create!(title: "아이템 있는 리스트", user_id: @user.id)
    list.items.create!(title: "할일 1")
    list.items.create!(title: "할일 2")

    assert_difference "Todo::Item.count", -2 do
      Todo::DataCleaner.call(user_id: @user.id)
    end
  end

  test "삭제할 데이터가 없어도 예외 없이 동작한다" do
    assert_nothing_raised do
      Todo::DataCleaner.call(user_id: @user.id)
    end
  end
end
