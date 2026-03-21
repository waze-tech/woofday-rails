class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @featured_pros = ProProfile.verified.limit(6)
  end
end
