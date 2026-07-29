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

      respond_to_change("할 일이 수정되었습니다.")
    rescue ActiveRecord::RecordInvalid
      respond_with_error("할 일 수정에 실패했습니다.", redirect_url: todo.list_path(@list))
    end

    def destroy
      @item.destroy!
      respond_to_change("할 일이 삭제되었습니다.")
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

    def respond_to_change(message)
      respond_to do |format|
        format.turbo_stream do
          @list.reload
          flash.now[:notice] = message
        end
        format.html { redirect_to todo.list_path(@list), status: :see_other, notice: message }
      end
    end
  end
end
