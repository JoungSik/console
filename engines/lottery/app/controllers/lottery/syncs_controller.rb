module Lottery
  class SyncsController < ApplicationController
    before_action :require_account

    def create
      Synchronizer.call(@account)
      redirect_to lottery.root_path, status: :see_other, notice: t("lottery.syncs.flash.synced")
    rescue DhLottery::Error => error
      redirect_to lottery.root_path, status: :see_other, alert: lottery_error_message(error)
    end
  end
end
