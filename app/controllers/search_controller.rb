class SearchController < ApplicationController
  allow_unauthenticated_access

  def index
    @pros = ProProfile.includes(:user, :reviews)

    if params[:service].present?
      @pros = @pros.by_service(params[:service])
    end

    if params[:location].present?
      @pros = @pros.by_location(params[:location])
    end

    @pros = @pros.order(verified: :desc, created_at: :desc)
  end
end
