class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[ show edit update destroy ]

  # GET /todo_lists or /todo_lists.json
  def index
    @todo_lists = TodoList.includes(:not_completed_todos).where(user: current_user)
    @todo_lists = @todo_lists.public_send(params[:archive].presence ? :archived : :not_archived)
  end

  # GET /todo_lists/1 or /todo_lists/1.json
  def show
  end

  # GET /todo_lists/new
  def new
    @todo_list = TodoList.new
  end

  # GET /todo_lists/1/edit
  def edit
  end

  # POST /todo_lists or /todo_lists.json
  def create
    @todo_list = TodoList.new(todo_list_params)

    respond_to do |format|
      if @todo_list.save
        format.html { redirect_to @todo_list, notice: t("messages.success.created", resource: t("navigation.todo_links")) }
        format.json { render :show, status: :created, location: @todo_list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @todo_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todo_lists/1 or /todo_lists/1.json
  def update
    respond_to do |format|
      if @todo_list.update(todo_list_params)
        format.html { redirect_to @todo_list, notice: t("messages.success.updated", resource: t("navigation.todo_links")) }
        format.json { render :show, status: :ok, location: @todo_list }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @todo_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todo_lists/1 or /todo_lists/1.json
  def destroy
    @todo_list.destroy!

    respond_to do |format|
      format.html { redirect_to todo_lists_path, status: :see_other, notice: t("messages.success.deleted", resource: t("navigation.todo_links")) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_todo_list
    @todo_list = TodoList.find_by!(id: params.expect(:id), user: current_user)
  end

  # Only allow a list of trusted parameters through.
  def todo_list_params
    permitted_params = params.require(:todo_list).permit(:title, :archive,
                                                         todos_attributes: [ :id, :title, :completed, :due_date, :_destroy ])
                             .merge(user_id: current_user.id)

    # Handle archive checkbox
    permitted_params[:archived_at] = permitted_params[:archive] == "1" ? Time.current : nil
    permitted_params.except(:archive)
  end
end
