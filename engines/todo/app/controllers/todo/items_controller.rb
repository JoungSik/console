module Todo
  class ItemsController < ApplicationController
    before_action :set_list
    before_action :set_item

    def update
      if @item.update(item_params)
        redirect_to todo.list_path(@list), notice: "할 일이 수정되었습니다."
      else
        redirect_to todo.list_path(@list), alert: "할 일 수정에 실패했습니다."
      end
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
  end
end
