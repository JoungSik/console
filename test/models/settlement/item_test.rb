require "test_helper"

class Settlement::ItemTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @gathering = Settlement::Gathering.create!(
      title: "팀 회식", user_id: @user.id
    )
    @member1 = @gathering.members.create!(name: "홍길동")
    @member2 = @gathering.members.create!(name: "김철수")
    @member3 = @gathering.members.create!(name: "이영희")
    @round = @gathering.rounds.create!(name: "1차")
  end

  test "total 계산 (수량 x 금액)" do
    item = @round.items.create!(name: "삼겹살", quantity: 2, amount: 15000)
    assert_equal 30000, item.total
  end

  test "is_shared면 라운드 전체 멤버 반환" do
    item = @round.items.create!(name: "공통 음료", amount: 9000, is_shared: true)
    assert_equal 3, item.responsible_members.count
  end

  test "태그된 멤버가 없으면 라운드 전체 멤버 반환" do
    item = @round.items.create!(name: "삼겹살", amount: 30000)
    assert_equal 3, item.responsible_members.count
  end

  test "태그된 멤버가 있으면 태그된 멤버만 반환" do
    item = @round.items.create!(name: "소주", amount: 5000)
    item.item_members.create!(member: @member1)
    item.item_members.create!(member: @member2)
    assert_equal 2, item.responsible_members.count
  end

  test "members는 id 순서로 반환된다" do
    item = @round.items.create!(name: "소주", amount: 5000)
    item.item_members.create!(member: @member3)
    item.item_members.create!(member: @member1)

    assert_equal [@member1.id, @member3.id], item.members.pluck(:id)
  end

  test "이름 없으면 유효하지 않다" do
    item = @round.items.build(name: nil, amount: 1000)
    assert_not item.valid?
  end

  test "수량 0이면 유효하지 않다" do
    item = @round.items.build(name: "삼겹살", quantity: 0, amount: 1000)
    assert_not item.valid?
  end
end
