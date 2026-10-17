require "test_helper"
require "support/lottery/fake_client"

class Lottery::DataCleanerTest < ActiveSupport::TestCase
  include Lottery::FakeClientHelper

  test "대상 유저의 계정과 구매내역만 삭제한다" do
    account = create_lottery_account(users(:test_user))
    account.purchase_records.create!(product_name: "로또6/45")
    other_account = create_lottery_account(users(:other_user))

    Lottery::DataCleaner.call(user_id: users(:test_user).id)

    assert_not Lottery::Account.exists?(account.id)
    assert_equal 0, Lottery::PurchaseRecord.where(account_id: account.id).count
    assert Lottery::Account.exists?(other_account.id)
  end
end
