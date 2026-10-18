require "test_helper"
require "support/lottery/fake_client"

class Lottery::PurchasesTest < ActionDispatch::IntegrationTest
  include Lottery::FakeClientHelper

  ROUND = 1246

  setup do
    travel_to Time.zone.parse("2026-10-14 12:00")
    @user = users(:test_user)
    sign_in_as @user
    @account = create_lottery_account(@user, purchasable: 41_000)
  end

  test "구매 화면에 다섯 게임 입력란을 보여준다" do
    get lottery.new_purchase_url

    assert_response :success
    assert_select "#lottery_games input[type='text']", count: 5
    assert_select "input[name='order[round]'][value='#{ROUND}']"
  end

  test "구매 전에 회차와 번호와 결제 금액을 확인한다" do
    fake_client = Lottery::FakeClient.new

    use_fake_lottery_client(fake_client) do
      get lottery.preview_purchases_url, params: order_params("0" => { selected: "1", numbers: "1,2,3,4,5,6" }, "1" => { selected: "1", numbers: "" })
    end

    assert_response :success
    assert_select "#lottery_order_summary li", text: "A 수동 1 2 3 4 5 6"
    assert_select "#lottery_order_summary li", text: "B 자동"
    assert_match "2,000원", response.body
    assert_select "input[type='hidden'][name='order[request_token]']:not([value=''])"
    assert_empty fake_client.calls
  end

  test "번호가 잘못되면 구매 화면에서 안내한다" do
    get lottery.preview_purchases_url, params: order_params("0" => { selected: "1", numbers: "1,1" })

    assert_response :unprocessable_entity
    assert_select "#lottery_games"
    assert_select "li", text: /중복된 번호/
  end

  test "구매하면 확정 번호를 안내하고 개요로 이동한다" do
    fake_client = Lottery::FakeClient.new

    use_fake_lottery_client(fake_client) do
      post lottery.purchases_url, params: order_params("0" => { selected: "1", numbers: "" })
    end

    assert_response :see_other
    assert_redirected_to lottery.root_url
    assert_match "A 자동 3 11 19 27 35 43", flash[:notice]
    assert fake_client.called?(:buy_lotto645)
  end

  test "같은 주문을 다시 보내면 한 번만 구매한다" do
    fake_client = Lottery::FakeClient.new
    params = order_params(request_token: "token-1", "0" => { selected: "1", numbers: "" })

    use_fake_lottery_client(fake_client) do
      post lottery.purchases_url, params: params
      post lottery.purchases_url, params: params
    end

    assert_response :see_other
    assert_redirected_to lottery.root_url
    assert_equal I18n.t("lottery.purchases.flash.duplicated"), flash[:alert]
    assert_equal 1, fake_client.calls.count { |name, _| name == :buy_lotto645 }
  end

  test "확인 단계를 거치지 않은 주문은 구매하지 않는다" do
    fake_client = Lottery::FakeClient.new

    use_fake_lottery_client(fake_client) do
      post lottery.purchases_url, params: order_params(request_token: "", "0" => { selected: "1", numbers: "" })
    end

    assert_redirected_to lottery.root_url
    assert_not fake_client.called?(:buy_lotto645)
  end

  test "구매에 실패하면 원인을 안내한다" do
    fake_client = Lottery::FakeClient.new(errors: { buy_lotto645: DhLottery::InsufficientDepositError.new("부족") })

    use_fake_lottery_client(fake_client) do
      post lottery.purchases_url, params: order_params("0" => { selected: "1", numbers: "" })
    end

    assert_response :unprocessable_entity
    assert_match I18n.t("lottery.errors.insufficient_deposit"), response.body
  end

  test "회차가 바뀐 주문은 구매하지 않는다" do
    fake_client = Lottery::FakeClient.new

    use_fake_lottery_client(fake_client) do
      post lottery.purchases_url, params: order_params(round: ROUND - 1, "0" => { selected: "1", numbers: "" })
    end

    assert_response :unprocessable_entity
    assert_not fake_client.called?(:buy_lotto645)
    assert_select "input[name='order[round]'][value='#{ROUND}']"
  end

  private

  def order_params(round: ROUND, request_token: SecureRandom.uuid, **games)
    { order: { round: round, request_token: request_token, games: games } }
  end
end
