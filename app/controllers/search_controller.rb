class SearchController < ApplicationController
  allow_unauthenticated_access

  def index
    @pros = ProProfile.setup_complete.includes(:user, :reviews, :services)

    # Location filter
    if params[:location].present?
      @pros = @pros.by_location(params[:location])
    end

    # Service type filter
    if params[:service_type].present?
      @pros = @pros.joins(:services).where("services.name ILIKE ?", "%#{params[:service_type]}%").distinct
    end

    # Pet type filter (for services that support that pet type)
    # TODO: Add pet_types array to services table

    # Minimum rating filter
    if params[:min_rating].present?
      min = params[:min_rating].to_i
      @pros = @pros.select { |p| p.average_rating >= min }
    end

    # Has availability this week
    if params[:available_this_week] == "1"
      @pros = @pros.select(&:has_availability?)
    end

    # Sort
    case params[:sort]
    when "rating"
      @pros = @pros.sort_by { |p| -p.average_rating }
    when "reviews"
      @pros = @pros.sort_by { |p| -p.total_reviews }
    when "newest"
      @pros = @pros.sort_by { |p| -p.created_at.to_i }
    else
      # Default: verified first, then by rating
      @pros = @pros.sort_by { |p| [p.is_verified ? 0 : 1, -p.average_rating] }
    end

    # Ensure it's an array for views
    @pros = @pros.to_a
  end
end
