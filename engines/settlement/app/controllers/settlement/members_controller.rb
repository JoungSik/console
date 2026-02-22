module Settlement
  class MembersController < ApplicationController
    before_action :set_gathering

    def create
      @member = @gathering.members.build(member_params)

      if @member.save
        redirect_to settlement.gathering_path(@gathering), notice: "참석자가 추가되었습니다."
      else
        redirect_to settlement.gathering_path(@gathering), alert: @member.errors.full_messages.join(", ")
      end
    end

    def destroy
      @member = @gathering.members.find(params[:id])
      @member.destroy!
      redirect_to settlement.gathering_path(@gathering), notice: "참석자가 삭제되었습니다."
    end

    private

    def set_gathering
      @gathering = Gathering.by_user(current_user_id).find(params[:gathering_id])
    end

    def member_params
      params.require(:member).permit(:name)
    end
  end
end
