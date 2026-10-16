module Inspiration
  class IdeasController < ApplicationController
    before_action :set_idea, only: %i[show edit update destroy]

    def index
      @idea = Idea.new
      @status_filter = status_filter_param
      @ideas = filtered_ideas
    end

    def show
      @notes = @idea.notes.chronological
      @note = @idea.notes.build
    end

    def edit
    end

    def create
      @idea = Idea.new(idea_params)

      if @idea.save
        respond_to do |format|
          format.turbo_stream do
            @status_filter = nil
            @ideas = filtered_ideas
            @idea = Idea.new
            flash.now[:notice] = "아이디어가 저장되었습니다."
          end
          format.html { redirect_to inspiration.root_path, status: :see_other, notice: "아이디어가 저장되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "idea_composer",
              partial: "inspiration/ideas/form",
              locals: { idea: @idea }
            ), status: :unprocessable_entity
          end
          format.html do
            @status_filter = nil
            @ideas = filtered_ideas
            render :index, status: :unprocessable_entity
          end
        end
      end
    end

    def update
      if @idea.update(idea_params)
        refresh_or_redirect_to inspiration.idea_path(@idea), status: :see_other, notice: "아이디어가 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @idea.destroy!

      if params[:source] == "index"
        respond_to do |format|
          format.turbo_stream do
            @status_filter = status_filter_param
            @ideas = filtered_ideas
            flash.now[:notice] = "아이디어가 삭제되었습니다."
          end
          format.html { redirect_to inspiration.root_path, status: :see_other, notice: "아이디어가 삭제되었습니다." }
        end
      else
        recede_or_redirect_to inspiration.root_path, status: :see_other, notice: "아이디어가 삭제되었습니다."
      end
    end

    private

    def set_idea
      @idea = current_user_ideas.find(params[:id])
    end

    def current_user_ideas
      Idea.by_user(current_user_id)
    end

    def filtered_ideas
      ideas = current_user_ideas.recent
      @status_filter ? ideas.where(status: @status_filter) : ideas
    end

    def status_filter_param
      params[:status].presence_in(Idea.statuses.keys)
    end

    def idea_params
      params.require(:idea).permit(:title, :body, :reference_url, :status).merge(user_id: current_user_id)
    end
  end
end
