class CollectionsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]
  before_action :set_collection, only: %i[ show ]

  # GET /collections or /collections.json
  def index
    @collections = Collection.is_public.order(id: :desc)
  end

  # GET /collections/1 or /collections/1.json
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_collection
    @collection = Collection.find_by_hashid!(params.expect(:id))
  end
end
