module Bookmark
  class GroupsController < ApplicationController
    before_action :set_group, only: %i[show edit update destroy]

    def index
      @groups = Group.by_user(current_user_id).order(id: :desc)
    end

    def show
    end

    def new
      @group = Group.new
    end

    def edit
    end

    def create
      @group = Group.new(group_params)

      if @group.save
        redirect_to bookmark.group_path(@group), notice: "북마크 그룹이 생성되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @group.update(group_params)
        redirect_to bookmark.group_path(@group), notice: "북마크 그룹이 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @group.destroy!
      redirect_to bookmark.groups_path, status: :see_other, notice: "북마크 그룹이 삭제되었습니다."
    end

    private

    def set_group
      @group = Group.by_user(current_user_id).find_universal(params[:id])
    end

    def group_params
      params.require(:group).permit(
        :title, :description, :is_public,
        links_attributes: [ :id, :title, :url, :description, :_destroy ]
      ).merge(user_id: current_user_id)
    end
  end
end
