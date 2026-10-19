require "test_helper"
require "support/lottery/fake_client"

class Lottery::SynchronizerTest < ActiveSupport::TestCase
  include Lottery::FakeClientHelper

  setup do
    @user = users(:test_user)
    @account = create_lottery_account(@user)
  end

  test "예치금과 최근 구매내역을 저장한다" do
    fake_client = Lottery::FakeClient.new(entries: [ Lottery::FakeClient.build_entry(prize_amount: 5_000, result: "당첨") ])

    use_fake_lottery_client(fake_client) { Lottery::Synchronizer.call(@account) }

    @account.reload
    assert_equal 41_000, @account.purchasable
    assert_equal 45_000, @account.total_deposit
    assert @account.synced?
    assert_equal [ 5_000 ], @account.purchase_records.pluck(:prize_amount)
    assert_equal "lotto_user", fake_client.open_options[:user_id]
    assert_equal "lotto_pass", fake_client.open_options[:password_provider].call
  end

  test "구매내역이 한 페이지를 넘으면 모든 페이지를 저장한다" do
    entries = Array.new(101) { |index| Lottery::FakeClient.build_entry(order_no: "ORDER-#{index}") }
    fake_client = Lottery::FakeClient.new(entries: entries)

    use_fake_lottery_client(fake_client) { Lottery::Synchronizer.call(@account) }

    assert_equal 101, @account.purchase_records.count
    assert_equal [ 1, 2 ], fake_client.calls.select { |name, _| name == :purchase_history }.map { |_, arguments| arguments[:page] }
  end

  test "구매내역이 조회 한도를 넘으면 기존 내역을 지우지 않고 중단한다" do
    existing_record = @account.purchase_records.create!(product_name: "로또6/45", purchased_on: 3.days.ago.to_date)
    page_limit = Lottery::Synchronizer::MAX_HISTORY_PAGES * Lottery::Synchronizer::HISTORY_PAGE_SIZE
    fake_client = Lottery::FakeClient.new(entries: Array.new(page_limit) { |index| Lottery::FakeClient.build_entry(order_no: "ORDER-#{index}") })

    use_fake_lottery_client(fake_client) do
      assert_raises(Lottery::Synchronizer::HistoryOverflowError) { Lottery::Synchronizer.call(@account) }
    end

    assert Lottery::PurchaseRecord.exists?(existing_record.id)
  end

  test "조회 기간의 기존 내역은 새 결과로 교체하고 이전 내역은 유지한다" do
    old_record = @account.purchase_records.create!(product_name: "로또6/45", purchased_on: 60.days.ago.to_date)
    @account.purchase_records.create!(product_name: "로또6/45", purchased_on: 3.days.ago.to_date, result: "미추첨")
    fake_client = Lottery::FakeClient.new(entries: [ Lottery::FakeClient.build_entry(purchased_on: 3.days.ago.to_date, result: "낙첨") ])

    use_fake_lottery_client(fake_client) { Lottery::Synchronizer.call(@account) }

    assert_equal [ "낙첨", nil ], @account.purchase_records.recent.pluck(:result)
    assert Lottery::PurchaseRecord.exists?(old_record.id)
  end

  test "아이디를 바꾸면 이전 계정의 내역을 모두 지운다" do
    @account.purchase_records.create!(product_name: "로또6/45", purchased_on: 60.days.ago.to_date)
    @account.login_id = "new_user"

    use_fake_lottery_client { Lottery::Synchronizer.call(@account) }

    assert_empty @account.purchase_records.reload
  end

  test "새 계정은 동기화에 성공해야 저장된다" do
    account = Lottery::Account.new(user_id: users(:other_user).id, login_id: "new_user", password: "secret")
    fake_client = Lottery::FakeClient.new(errors: { balance: DhLottery::AuthenticationError.new("로그인 실패") })

    assert_raises(DhLottery::AuthenticationError) do
      use_fake_lottery_client(fake_client) { Lottery::Synchronizer.call(account) }
    end
    assert_not account.persisted?
  end
end
