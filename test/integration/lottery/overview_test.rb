require "test_helper"
require "support/lottery/fake_client"

class Lottery::OverviewTest < ActionDispatch::IntegrationTest
  include Lottery::FakeClientHelper

  setup do
    @user = users(:test_user)
    sign_in_as @user
    @account = create_lottery_account(@user, purchasable: 41_000, total_deposit: 45_000, synced_at: Time.current)
  end

  test "예치금과 구매·당첨 내역을 보여준다" do
    @account.purchase_records.create!(product_name: "로또6/45", round: 1245, result: "5등 당첨", prize_amount: 5_000, purchased_on: 3.days.ago.to_date)

    get lottery.root_url

    assert_response :success
    assert_select "title", text: "동행복권"
    assert_select "#lottery_balance", text: /41,000원/
    assert_select "#purchase_records", text: /1245회/
    assert_select "#purchase_records", text: /5,000원/
  end

  test "조회 기간보다 오래된 내역은 보이지 않는다" do
    @account.purchase_records.create!(product_name: "로또6/45", round: 1200, purchased_on: 60.days.ago.to_date)
    @account.purchase_records.create!(product_name: "로또6/45", round: 1245, purchased_on: 3.days.ago.to_date)

    get lottery.root_url

    assert_select "#purchase_records", text: /1245회/
    assert_select "#purchase_records", text: /1200회/, count: 0
  end

  test "다른 사용자의 내역은 보이지 않는다" do
    other_account = create_lottery_account(users(:other_user))
    other_account.purchase_records.create!(product_name: "연금복권720+", round: 999)

    get lottery.root_url

    assert_select "#purchase_records", text: /999회/, count: 0
  end

  test "새로고침하면 동행복권에서 다시 불러온다" do
    fake_client = Lottery::FakeClient.new(entries: [ Lottery::FakeClient.build_entry(round: 1246) ])

    use_fake_lottery_client(fake_client) { post lottery.sync_url }

    assert_response :see_other
    assert_redirected_to lottery.root_url
    assert_equal [ 1246 ], @account.purchase_records.pluck(:round)
  end

  test "새로고침에 실패하면 원인을 안내한다" do
    fake_client = Lottery::FakeClient.new(errors: { balance: DhLottery::MaintenanceError.new("점검") })

    use_fake_lottery_client(fake_client) { post lottery.sync_url }

    assert_redirected_to lottery.root_url
    assert_equal I18n.t("lottery.errors.maintenance"), flash[:alert]
  end

  test "대시보드 위젯에 구매 가능 금액을 보여준다" do
    get main_app.root_url

    assert_response :success
    assert_select "a[href='#{lottery.root_path}']"
    assert_match "41,000원", response.body
  end
end
