class ServiceWorkerController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection

  def index
    @firebase_web_config = Fcm::Configuration.firebase_web_app
    @firebase_web_configured = Fcm::Configuration.web_configured?
    response.headers["Content-Type"] = "application/javascript"
    response.headers["Service-Worker-Allowed"] = "/"
  end
end
