class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "blank"

  def terms; end

  def privacy; end
end
