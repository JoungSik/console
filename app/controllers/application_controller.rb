class ApplicationController < ActionController::Base
  include Authentication

  helper_method :turbo_native_app?

  private

  def turbo_native_app?
    request.user_agent.to_s.include?("Turbo Native")
  end
end
