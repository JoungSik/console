module FlashErrorResponse
  extend ActiveSupport::Concern

  private

  def respond_with_error(message, redirect_url:)
    respond_to do |format|
      format.turbo_stream do
        flash.now[:alert] = message
        render turbo_stream: turbo_stream.update("flash", partial: "layouts/shared/alert"),
          status: :unprocessable_entity
      end
      format.html { redirect_to redirect_url, status: :see_other, alert: message }
    end
  end
end
