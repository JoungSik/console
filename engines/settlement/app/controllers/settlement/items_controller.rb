module Settlement
  class ItemsController < ApplicationController
    before_action :set_gathering
    before_action :set_round
    before_action :set_item, only: %i[update destroy]

    def create
      @item = @round.items.build(item_params)

      if @item.save
        update_item_members(@item)
        redirect_to settlement.gathering_round_path(@gathering, @round), notice: "항목이 추가되었습니다."
      else
        redirect_to settlement.gathering_round_path(@gathering, @round), alert: @item.errors.full_messages.join(", ")
      end
    end

    def update
      if @item.update(item_params)
        update_item_members(@item)
        redirect_to settlement.gathering_round_path(@gathering, @round), notice: "항목이 수정되었습니다."
      else
        redirect_to settlement.gathering_round_path(@gathering, @round), alert: @item.errors.full_messages.join(", ")
      end
    end

    def destroy
      @item.destroy!
      redirect_to settlement.gathering_round_path(@gathering, @round), notice: "항목이 삭제되었습니다."
    end

    private

    def set_gathering
      @gathering = Gathering.by_user(current_user_id).find(params[:gathering_id])
    end

    def set_round
      @round = @gathering.rounds.find(params[:round_id])
    end

    def set_item
      @item = @round.items.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:name, :quantity, :amount, :is_shared)
    end

    def update_item_members(item)
      member_ids = (params.dig(:item, :member_ids) || []).map(&:to_i)
      item.member_ids = @gathering.member_ids & member_ids
    end
  end
end
