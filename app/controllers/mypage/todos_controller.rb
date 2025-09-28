class Mypage::TodosController < ApplicationController
  before_action :set_todo, only: %i[ update destroy ]

  # PATCH/PUT /mypage/todos/1 or /mypage/todos/1.json
  def update
    respond_to do |format|
      if @todo.update(todo_params)
        format.html { redirect_to [ :mypage, @todo.todo_list ], notice: updated_flash_message(t("activerecord.models.todo")) }
        format.json { render :show, status: :ok, location: [ :mypage, @todo.todo_list ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mypage/todos/1 or /mypage/todos/1.json
  def destroy
    @todo.destroy!

    respond_to do |format|
      format.html { redirect_to [ :mypage, @todo.todo_list ], status: :see_other, notice: deleted_flash_message(t("activerecord.models.todo")) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_todo
    @todo = Todo.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def todo_params
    params.require(:todo).permit(:completed)
  end
end
