module Lottery
  module Synchronizer
    HISTORY_DAYS = 30
    HISTORY_PAGE_SIZE = 100
    MAX_HISTORY_PAGES = 10

    class HistoryOverflowError < DhLottery::Error; end

    module_function

    def call(account)
      history_from = HISTORY_DAYS.days.ago.to_date
      balance, entries = ClientSession.open(account) do |client|
        [ client.balance, fetch_history(client, history_from) ]
      end

      account.transaction do
        stale_records = account.login_id_changed? ? account.purchase_records : account.purchase_records.where(purchased_on: history_from..)
        stale_records.delete_all if account.persisted?
        account.update!(total_deposit: balance.total_deposit, purchasable: balance.purchasable, synced_at: Time.current)
        entries.each { |entry| account.purchase_records.create!(PurchaseRecord.attributes_from(entry)) }
      end
    end

    # 일부 페이지만 받은 채 기간 내역을 교체하면 나머지 내역이 사라지므로 마지막 페이지까지 모두 받는다.
    def fetch_history(client, from)
      (1..MAX_HISTORY_PAGES).each_with_object([]) do |page, entries|
        page_entries = client.purchase_history(from:, page:, per_page: HISTORY_PAGE_SIZE)
        entries.concat(page_entries)
        return entries if page_entries.size < HISTORY_PAGE_SIZE
      end

      raise HistoryOverflowError, "구매내역이 #{MAX_HISTORY_PAGES}페이지를 넘습니다."
    end
  end
end
