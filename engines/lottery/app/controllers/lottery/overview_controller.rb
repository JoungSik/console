module Lottery
  class OverviewController < ApplicationController
    before_action :require_account

    def show
      @purchase_records = @account.purchase_records.within_history.recent
    end
  end
end
