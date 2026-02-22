module Settlement
  class GatheringsController < ApplicationController
    before_action :set_gathering, only: %i[show edit update destroy result]

    def index
      @gatherings = Gathering.by_user(current_user_id).order(id: :desc)
    end

    def show
    end

    def new
      @gathering = Gathering.new(gathering_date: Date.current)
    end

    def create
      @gathering = Gathering.new(gathering_params)

      begin
        Gathering.transaction do
          @gathering.save!
          # 주선자(현재 사용자)를 첫 번째 참석자로 자동 추가
          @gathering.members.create!(name: current_user_name)
        end
        redirect_to settlement.gathering_path(@gathering), notice: "모임이 생성되었습니다."
      rescue ActiveRecord::RecordInvalid
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @gathering.update(gathering_params)
        redirect_to settlement.gathering_path(@gathering), notice: "모임이 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @gathering.destroy!
      redirect_to settlement.gatherings_path, notice: "모임이 삭제되었습니다."
    end

    def result
      @calculator = Calculator.new(@gathering)
    end

    private

    def set_gathering
      @gathering = Gathering.by_user(current_user_id).find(params[:id])
    end

    def gathering_params
      params.require(:gathering).permit(:title, :gathering_date, :memo, :remainder_method)
            .merge(user_id: current_user_id)
    end
  end
end
