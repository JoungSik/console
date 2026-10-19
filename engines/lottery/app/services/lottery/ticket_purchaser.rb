module Lottery
  module TicketPurchaser
    class DuplicateRequestError < StandardError; end

    module_function

    def call(account, order)
      claim_request(account, order.request_token)
      result = ClientSession.open(account) do |client|
        client.buy_lotto645(order.tickets, round: order.round)
      end
      refresh_after_purchase(account)
      result
    end

    # 응답을 못 받은 재전송도 결제될 수 있으므로 확인 단계에서 받은 키는 결과와 상관없이 한 번만 쓴다.
    def claim_request(account, token)
      raise DuplicateRequestError if token.blank?

      account.purchase_requests.create!(token: token)
    rescue ActiveRecord::RecordNotUnique
      raise DuplicateRequestError
    end

    # 구매는 이미 성립했으므로 동기화 실패가 구매 결과 안내를 막지 않게 한다.
    def refresh_after_purchase(account)
      Synchronizer.call(account)
    rescue DhLottery::Error => error
      Rails.logger.warn("[lottery] 구매 후 동기화 실패: #{error.class}: #{error.message}")
    end
  end
end
