require "test_helper"

class Settlement::RoundTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @gathering = Settlement::Gathering.create!(
      title: "팀 회식", user_id: @user.id
    )
    @gathering.members.create!(name: "홍길동")
    @gathering.members.create!(name: "김철수")
  end

  test "라운드 생성 시 모임 전체 멤버가 자동 추가된다" do
    round = @gathering.rounds.create!(name: "1차 고기")
    assert_equal 2, round.members.count
    assert_equal @gathering.members.pluck(:id).sort, round.members.pluck(:id).sort
  end

  test "members는 id 순서로 반환된다" do
    round = @gathering.rounds.create!(name: "1차")
    member_ids = round.members.pluck(:id)

    assert_equal member_ids.sort, member_ids
  end

  test "멤버 제거 시 해당 멤버의 항목 태그도 함께 정리된다" do
    round = @gathering.rounds.create!(name: "1차")
    member1, member2 = round.members.order(:id).to_a
    item = round.items.create!(name: "소주", amount: 5000)
    item.item_members.create!(member: member1)
    item.item_members.create!(member: member2)

    removed_member_ids = [member1.id]
    Settlement::ItemMember.where(item_id: round.item_ids, member_id: removed_member_ids).destroy_all
    round.member_ids = round.member_ids - removed_member_ids

    assert_not_includes round.members.reload.pluck(:id), member1.id
    assert_not_includes item.members.reload.pluck(:id), member1.id
    assert_includes item.members.pluck(:id), member2.id
  end

  test "이름 없으면 유효하지 않다" do
    round = @gathering.rounds.build(name: nil)
    assert_not round.valid?
  end

  test "total_amount 계산" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "삼겹살", quantity: 2, amount: 15000)
    round.items.create!(name: "소주", quantity: 3, amount: 5000)

    assert_equal 45000, round.total_amount
  end
end
