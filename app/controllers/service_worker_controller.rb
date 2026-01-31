# Service Worker 파일을 제공하는 컨트롤러
class ServiceWorkerController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection

  def index
    response.headers["Content-Type"] = "application/javascript"
    response.headers["Service-Worker-Allowed"] = "/"
  end
end
