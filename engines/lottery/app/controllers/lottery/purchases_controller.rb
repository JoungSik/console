module Lottery
  class PurchasesController < ApplicationController
    before_action :require_account

    def new
      @order = TicketOrder.new
    end

    def preview
      @order = TicketOrder.new(**order_params)
      return render(:new, status: :unprocessable_entity) unless @order.valid?

      @order.request_token = SecureRandom.uuid
    end

    def create
      @order = TicketOrder.new(**order_params)
      return render(:new, status: :unprocessable_entity) unless @order.valid?

      result = TicketPurchaser.call(@account, @order)
      redirect_to lottery.root_path, status: :see_other, notice: purchased_notice(result)
    rescue TicketPurchaser::DuplicateRequestError
      redirect_to lottery.root_path, status: :see_other, alert: t("lottery.purchases.flash.duplicated")
    rescue DhLottery::Error => error
      flash.now[:alert] = lottery_error_message(error)
      render :new, status: :unprocessable_entity
    end

    private

    def order_params
      permitted = params.require(:order).permit(:round, :request_token, games: %i[selected numbers])
      { round: permitted[:round], request_token: permitted[:request_token], games: permitted[:games]&.to_h }
    end

    def purchased_notice(result)
      key = result.dry_run? ? "lottery.purchases.flash.dry_run" : "lottery.purchases.flash.purchased"
      t(key, round: result.round, count: @order.tickets.size, slots: purchased_slots(result).join(" / "))
    end

    # 모의 구매는 서버가 번호를 확정하지 않으므로 주문 요약을 대신 보여준다.
    def purchased_slots(result)
      return @order.summary if result.dry_run?

      result.slots.map { |slot| "#{slot.slot} #{slot.mode_name} #{slot.numbers.join(' ')}" }
    end
  end
end
