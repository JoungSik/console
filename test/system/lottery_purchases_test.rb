require "application_system_test_case"
require "support/lottery/fake_client"

class LotteryPurchasesTest < ApplicationSystemTestCase
  include Lottery::FakeClientHelper

  setup do
    travel_to Time.zone.parse("2026-10-14 12:00")
    @user = users(:test_user)
    sign_in_as @user
    create_lottery_account(@user, purchasable: 41_000)
  end

  test "번호 입력부터 구매 확인과 구매까지 Turbo 화면 전환으로 처리한다" do
    use_fake_lottery_client do |fake_client|
      visit lottery.new_purchase_url
      fill_in "order[games][0][numbers]", with: "1, 2, 3, 4, 5, 6"
      check "order_games_1_selected"
      click_button I18n.t("lottery.purchases.new.submit")

      assert_current_path lottery.preview_purchases_path, ignore_query: true
      within("#lottery_order_summary") do
        assert_text "A 수동 1 2 3 4 5 6"
        assert_text "B 자동"
      end

      visit current_url
      assert_selector "#lottery_order_summary li", count: 2

      click_button I18n.t("lottery.purchases.preview.submit")
      assert_current_path lottery.root_path
      assert_text "B 자동 3 11 19 27 35 43"
      assert fake_client.called?(:buy_lotto645)
    end
  end

  test "번호가 잘못되면 구매 화면에 오류를 보여준다" do
    visit lottery.new_purchase_url
    fill_in "order[games][0][numbers]", with: "1, 1"
    click_button I18n.t("lottery.purchases.new.submit")

    assert_text "중복된 번호"
    assert_field "order[games][0][numbers]", with: "1, 1"
  end
end
