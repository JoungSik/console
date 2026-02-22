module Todo
  class ListsController < ApplicationController
    before_action :set_list, only: %i[show edit update destroy]

    def index
      @lists = List.by_user(current_user_id).order(id: :desc)
    end

    def show
    end

    def new
      @list = List.new
    end

    def edit
    end

    def create
      @list = List.new(list_params)

      if @list.save
        redirect_to todo.list_path(@list), notice: "할 일 목록이 생성되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @list.update(list_params)
        redirect_to todo.list_path(@list), notice: "할 일 목록이 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @list.destroy!
      redirect_to todo.lists_path, status: :see_other, notice: "할 일 목록이 삭제되었습니다."
    end

    private

    def set_list
      @list = List.by_user(current_user_id).find(params[:id])
    end

    def list_params
      params.require(:list).permit(
        :title, :archive,
        items_attributes: [ :id, :title, :completed, :due_date, :url, :_destroy ]
      ).tap do |p|
        archive_value = p.delete(:archive)
        if archive_value == "1"
          p[:archived_at] = Time.current unless @list&.archived?
        else
          p[:archived_at] = nil
        end
      end.merge(user_id: current_user_id)
    end
  end
end
