require "test_helper"
require "support/lottery/fake_client"

class Lottery::TicketPurchaserTest < ActiveSupport::TestCase
  include Lottery::FakeClientHelper

  setup do
    travel_to Time.zone.parse("2026-10-14 12:00")
    @account = create_lottery_account(users(:test_user))
    @order = Lottery::TicketOrder.new(request_token: "token-1", games: { "0" => { selected: "1", numbers: "1,2,3,4,5,6" } })
  end

  test "주문한 회차로 구매한 뒤 내역을 다시 불러온다" do
    fake_client = Lottery::FakeClient.new

    result = use_fake_lottery_client(fake_client) { Lottery::TicketPurchaser.call(@account, @order) }

    assert_equal 1246, result.round
    assert_equal [ 1, 2, 3, 4, 5, 6 ], result.slots.first.numbers
    assert_equal({ tickets: @order.tickets, round: 1246 }, fake_client.calls.find { |name, _| name == :buy_lotto645 }.last)
    assert fake_client.called?(:purchase_history)
  end

  test "구매 후 동기화가 실패해도 구매 결과를 돌려준다" do
    fake_client = Lottery::FakeClient.new(errors: { balance: DhLottery::MaintenanceError.new("점검") })

    result = use_fake_lottery_client(fake_client) { Lottery::TicketPurchaser.call(@account, @order) }

    assert_equal 1, result.game_count
  end

  test "구매 실패는 그대로 전달한다" do
    fake_client = Lottery::FakeClient.new(errors: { buy_lotto645: DhLottery::InsufficientDepositError.new("예치금 부족") })

    assert_raises(DhLottery::InsufficientDepositError) do
      use_fake_lottery_client(fake_client) { Lottery::TicketPurchaser.call(@account, @order) }
    end
    assert_not fake_client.called?(:balance)
  end

  test "구매를 시도한 요청 키로는 결과와 상관없이 다시 구매하지 않는다" do
    failing_client = Lottery::FakeClient.new(errors: { buy_lotto645: DhLottery::TransportError.new("응답 없음") })
    retry_client = Lottery::FakeClient.new

    assert_raises(DhLottery::TransportError) do
      use_fake_lottery_client(failing_client) { Lottery::TicketPurchaser.call(@account, @order) }
    end
    assert_raises(Lottery::TicketPurchaser::DuplicateRequestError) do
      use_fake_lottery_client(retry_client) { Lottery::TicketPurchaser.call(@account, @order) }
    end
    assert_not retry_client.called?(:buy_lotto645)
  end
end
