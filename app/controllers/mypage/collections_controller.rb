class Mypage::CollectionsController < Mypage::ApplicationController
  before_action :set_collection, only: %i[ show edit update destroy ]

  # GET /mypage/collections or /mypage/collections.json
  def index
    @collections = Collection.where(user: current_user)
  end

  # GET /mypage/collections/1 or /mypage/collections/1.json
  def show
  end

  # GET /mypage/collections/new
  def new
    @collection = Collection.new
  end

  # GET /mypage/collections/1/edit
  def edit
  end

  # POST /mypage/collections or /mypage/collections.json
  def create
    @collection = Collection.new(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to mypage_collection_path(@collection), notice: created_flash_message(t("activerecord.models.collection")) }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mypage/collections/1 or /mypage/collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to mypage_collection_path(@collection), notice: updated_flash_message(t("activerecord.models.collection")) }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mypage/collections/1 or /mypage/collections/1.json
  def destroy
    @collection.destroy!

    respond_to do |format|
      format.html { redirect_to mypage_collections_path, status: :see_other, notice: deleted_flash_message(t("activerecord.models.collection")) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_collection
    @collection = Collection.find_by_hashid!(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def collection_params
    params.require(:collection).permit(:title, :description, :is_public,
                                       links_attributes: [ :id, :title, :url, :description, :_destroy ])
          .merge(user_id: current_user.id)
  end
end
