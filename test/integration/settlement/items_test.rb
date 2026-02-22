require "test_helper"

class Settlement::ItemsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @gathering = Settlement::Gathering.create!(title: "항목 테스트 모임", user_id: @user.id)
    @member = @gathering.members.create!(name: @user.name)
    @round = @gathering.rounds.create!(name: "1차")
    @item = @round.items.create!(name: "테스트 항목", quantity: 1, amount: 10000)
  end

  teardown do
    Settlement::Gathering.where(user_id: @user.id).destroy_all
  end

  test "항목을 추가할 수 있다" do
    assert_difference "@round.items.count", 1 do
      post settlement.gathering_round_items_url(@gathering, @round), params: {
        item: { name: "새 항목", quantity: 2, amount: 5000 }
      }
    end
    assert_redirected_to settlement.gathering_round_url(@gathering, @round)
  end

  test "공유 비용 항목을 추가할 수 있다" do
    post settlement.gathering_round_items_url(@gathering, @round), params: {
      item: { name: "배달비", quantity: 1, amount: 3000, is_shared: true }
    }
    item = Settlement::Item.last
    assert item.is_shared
  end

  test "멤버를 지정하여 항목을 추가할 수 있다" do
    post settlement.gathering_round_items_url(@gathering, @round), params: {
      item: { name: "개인 메뉴", quantity: 1, amount: 15000, member_ids: [ @member.id ] }
    }
    item = Settlement::Item.last
    assert_includes item.member_ids, @member.id
  end

  test "항목을 수정할 수 있다" do
    patch settlement.gathering_round_item_url(@gathering, @round, @item), params: {
      item: { name: "수정된 항목", amount: 20000 }
    }
    assert_redirected_to settlement.gathering_round_url(@gathering, @round)
    assert_equal "수정된 항목", @item.reload.name
    assert_equal 20000, @item.amount
  end

  test "항목을 삭제할 수 있다" do
    assert_difference "@round.items.count", -1 do
      delete settlement.gathering_round_item_url(@gathering, @round, @item)
    end
    assert_redirected_to settlement.gathering_round_url(@gathering, @round)
  end
end
