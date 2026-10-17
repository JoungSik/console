require "test_helper"
require "support/lottery/fake_client"

class Lottery::PurchaseRecordTest < ActiveSupport::TestCase
  include Lottery::FakeClientHelper

  test "구매내역 항목에서 저장할 속성만 추린다" do
    entry = Lottery::FakeClient.build_entry(prize_amount: 5_000, result: "당첨")

    attributes = Lottery::PurchaseRecord.attributes_from(entry)

    assert_equal 5_000, attributes[:prize_amount]
    assert_equal "ORDER-1", attributes[:order_no]
    assert_not attributes.key?(:raw)
    assert_not attributes.key?(:details)
  end

  test "당첨금이 있으면 당첨이다" do
    account = create_lottery_account(users(:test_user))

    assert account.purchase_records.build(product_name: "로또6/45", prize_amount: 5_000).won?
    assert_not account.purchase_records.build(product_name: "로또6/45", prize_amount: 0).won?
  end
end
