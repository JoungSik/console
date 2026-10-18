module Lottery
  class ApplicationController < ::ApplicationController
    include Console::PluginInterface

    private

    def current_account
      @current_account ||= Account.find_by(user_id: current_user_id)
    end

    def require_account
      @account = current_account
      redirect_to lottery.new_account_path unless @account
    end

    def lottery_error_message(error)
      Rails.logger.warn("[lottery] #{error.class}: #{error.message}")
      ErrorMessage.for(error)
    end
  end
end
