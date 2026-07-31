module AdminAuthorization
  extend ActiveSupport::Concern

  include Authentication

  included do
    before_action :require_admin
  end

  private

  def require_admin
    return if current_user&.admin?

    head :forbidden
  end
end
