module Lottery
  module ErrorMessage
    # 하위 예외가 먼저 매칭되도록 순서를 유지한다.
    MESSAGE_KEYS = {
      DhLottery::PasswordChangeRequiredError => :password_change_required,
      DhLottery::AuthenticationError => :authentication_failed,
      DhLottery::MaintenanceError => :maintenance,
      DhLottery::RateLimitError => :rate_limited,
      DhLottery::InsufficientDepositError => :insufficient_deposit,
      DhLottery::PurchaseLimitError => :purchase_limit,
      DhLottery::RoundMismatchError => :round_mismatch,
      DhLottery::PurchaseError => :purchase_failed,
      DhLottery::TransportError => :transport_failed
    }.freeze
    DEFAULT_KEY = :unknown

    module_function

    def for(error)
      key = MESSAGE_KEYS.find { |error_class, _| error.is_a?(error_class) }&.last || DEFAULT_KEY
      I18n.t(key, scope: "lottery.errors")
    end
  end
end
