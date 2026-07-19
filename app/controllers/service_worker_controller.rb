class ServiceWorkerController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection

  def index
    response.headers["Content-Type"] = "application/javascript"
    response.headers["Service-Worker-Allowed"] = "/"
  end
end
