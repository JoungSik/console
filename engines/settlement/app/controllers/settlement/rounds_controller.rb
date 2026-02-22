module Settlement
  class RoundsController < ApplicationController
    before_action :set_gathering
    before_action :set_round, only: %i[show edit update destroy update_members]

    def show
    end

    def new
      @round = @gathering.rounds.build(
        name: "#{@gathering.rounds.count + 1}차",
        position: @gathering.rounds.count
      )
    end

    def create
      @round = @gathering.rounds.build(round_params)

      if @round.save
        redirect_to settlement.gathering_round_path(@gathering, @round), notice: "라운드가 추가되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @round.update(round_params)
        redirect_to settlement.gathering_round_path(@gathering, @round), notice: "라운드가 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @round.destroy!
      redirect_to settlement.gathering_path(@gathering), notice: "라운드가 삭제되었습니다."
    end

    def update_members
      member_ids = (params[:member_ids] || []).map(&:to_i)
      valid_member_ids = @gathering.member_ids & member_ids
      removed_member_ids = @round.member_ids - valid_member_ids

      Round.transaction do
        if removed_member_ids.any?
          ItemMember.where(item_id: @round.item_ids, member_id: removed_member_ids).destroy_all
        end

        @round.member_ids = valid_member_ids
      end
      redirect_to settlement.gathering_round_path(@gathering, @round), notice: "참석자가 수정되었습니다."
    end

    private

    def set_gathering
      @gathering = Gathering.by_user(current_user_id).find(params[:gathering_id])
    end

    def set_round
      @round = @gathering.rounds.includes(items: :members).find(params[:id])
    end

    def round_params
      params.require(:round).permit(:name, :position)
    end
  end
end
