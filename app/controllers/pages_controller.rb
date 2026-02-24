class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "blank"

  def terms
    loader = LegalPageLoader.load(:terms)
    @content = loader.to_html
    @effective_date = loader.effective_date
  end

  def privacy
    loader = LegalPageLoader.load(:privacy)
    @content = loader.to_html
    @effective_date = loader.effective_date
  end
end
