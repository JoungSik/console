class ApplicationController < ActionController::Base
  include Authentication
  include FlashErrorResponse
end
