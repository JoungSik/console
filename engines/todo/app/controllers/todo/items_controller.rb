module Todo
  class ItemsController < ApplicationController
    before_action :set_list
    before_action :set_item

    def update
      if completing?
        CompleteItemService.new(@item).call
      elsif uncompleting?
        UncompleteItemService.new(@item).call
      else
        @item.update!(item_params)
      end

      redirect_to todo.list_path(@list), notice: "할 일이 수정되었습니다."
    rescue ActiveRecord::RecordInvalid
      redirect_to todo.list_path(@list), alert: "할 일 수정에 실패했습니다."
    end

    def destroy
      @item.destroy!
      redirect_to todo.list_path(@list), status: :see_other, notice: "할 일이 삭제되었습니다."
    end

    private

    def set_list
      @list = List.by_user(current_user_id).find(params[:list_id])
    end

    def set_item
      @item = @list.items.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:completed)
    end

    def completing?
      item_params[:completed] == "true" && !@item.completed?
    end

    def uncompleting?
      item_params[:completed] == "false" && @item.completed?
    end
  end
end
