module Lottery
  class AccountsController < ApplicationController
    before_action :require_account, only: %i[edit update destroy]

    def new
      return redirect_to lottery.edit_account_path if current_account

      @account = Account.new
    end

    def create
      @account = Account.new(account_params.merge(user_id: current_user_id))
      connect(:new, notice: t("lottery.accounts.flash.created"))
    end

    def edit
    end

    def update
      @account.assign_attributes(account_params.compact_blank)
      connect(:edit, notice: t("lottery.accounts.flash.updated"))
    end

    def destroy
      @account.destroy!
      redirect_to main_app.root_path, status: :see_other, notice: t("lottery.accounts.flash.destroyed")
    end

    private

    def connect(template, notice:)
      if @account.valid? && synchronize
        redirect_to lottery.root_path, status: :see_other, notice: notice
      else
        render template, status: :unprocessable_entity
      end
    end

    def synchronize
      Synchronizer.call(@account)
      true
    rescue DhLottery::Error => error
      @account.errors.add(:base, lottery_error_message(error))
      false
    end

    def account_params
      params.require(:account).permit(:login_id, :password)
    end
  end
end
