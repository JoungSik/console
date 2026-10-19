module Inspiration
  class NotesController < ApplicationController
    before_action :set_idea

    def create
      @note = @idea.notes.build(note_params)

      if @note.save
        respond_to do |format|
          format.turbo_stream do
            @idea.reload
            @notes = @idea.notes.chronological
            @note = @idea.notes.build
            flash.now[:notice] = t("inspiration.notes.flash.created")
          end
          format.html { redirect_to inspiration.idea_path(@idea), status: :see_other, notice: t("inspiration.notes.flash.created") }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "note_composer",
              partial: "inspiration/notes/form",
              locals: { idea: @idea, note: @note }
            ), status: :unprocessable_entity
          end
          format.html do
            @notes = @idea.notes.chronological
            render "inspiration/ideas/show", status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @idea.notes.find(params[:id]).destroy!

      respond_to do |format|
        format.turbo_stream do
          @idea.reload
          @notes = @idea.notes.chronological
          flash.now[:notice] = t("inspiration.notes.flash.destroyed")
        end
        format.html { redirect_to inspiration.idea_path(@idea), status: :see_other, notice: t("inspiration.notes.flash.destroyed") }
      end
    end

    private

    def set_idea
      @idea = Idea.by_user(current_user_id).find(params[:idea_id])
    end

    def note_params
      params.require(:note).permit(:body)
    end
  end
end
