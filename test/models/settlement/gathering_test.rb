require "test_helper"

class Settlement::GatheringTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @gathering = Settlement::Gathering.new(
      title: "팀 회식",
      gathering_date: Date.current,
      user_id: @user.id
    )
  end

  test "유효한 모임이 저장된다" do
    assert @gathering.valid?
  end

  test "제목 없으면 유효하지 않다" do
    @gathering.title = nil
    assert_not @gathering.valid?
    assert @gathering.errors[:title].any?
  end

  test "제목 100자 초과 시 유효하지 않다" do
    @gathering.title = "가" * 101
    assert_not @gathering.valid?
  end

  test "user_id 없으면 유효하지 않다" do
    @gathering.user_id = nil
    assert_not @gathering.valid?
  end

  test "by_user 스코프로 사용자별 필터링" do
    @gathering.save!
    assert_includes Settlement::Gathering.by_user(@user.id), @gathering
    assert_empty Settlement::Gathering.by_user(0)
  end

  test "모임 삭제 시 참석자, 라운드도 삭제" do
    @gathering.save!
    @gathering.members.create!(name: "홍길동")
    @gathering.rounds.create!(name: "1차")

    assert_difference [ "Settlement::Member.count", "Settlement::Round.count" ], -1 do
      @gathering.destroy!
    end
  end
end
