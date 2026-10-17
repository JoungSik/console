module Lottery
  class DashboardComponent < Console::DashboardComponent
    RECENT_RECORDS_LIMIT = 5

    attr_reader :account, :recent_records

    def plugin_name = I18n.t("lottery.title")

    def load_data
      @account = Lottery::Account.find_by(user_id: user_id)
      @recent_records = account ? account.purchase_records.recent.limit(RECENT_RECORDS_LIMIT).load : []
      self
    end

    def partial_path = "lottery/dashboard/widget"
  end
end
