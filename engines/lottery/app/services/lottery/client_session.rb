module Lottery
  module ClientSession
    DRY_RUN_ENV = "LOTTERY_DRY_RUN"

    mattr_accessor :client_class, default: DhLottery::Client

    module_function

    def open(account, &block)
      client_class.open(
        user_id: account.login_id,
        password_provider: -> { account.password },
        logger: Rails.logger,
        dry_run: dry_run?,
        &block
      )
    end

    def dry_run?
      ENV[DRY_RUN_ENV] == "1"
    end
  end
end
