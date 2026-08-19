class NoticesController < ApplicationController
  def show
    @notice = Notice.visible_on.find(params[:id])
  end
end
