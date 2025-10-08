module Authorization
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  private

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_to root_path, alert: t("messages.errors.forbidden"), status: :see_other }
      format.turbo_stream { redirect_to root_path, alert: t("messages.errors.forbidden"), status: :see_other }
      format.json { render json: { error: t("messages.errors.forbidden") }, status: :forbidden }
    end
  end
end
