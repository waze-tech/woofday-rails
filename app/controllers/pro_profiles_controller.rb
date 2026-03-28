class ProProfilesController < ApplicationController
  allow_unauthenticated_access only: [:index, :show, :show_by_slug]
  before_action :set_pro_profile, only: [:show]
  before_action :set_own_profile, only: [:edit, :update]

  def index
    redirect_to search_path
  end

  def show
    @reviews = @pro_profile.reviews.published.recent.includes(:reviewer).limit(10)
    @services = @pro_profile.services.where("name IS NOT NULL")
    @photos = @pro_profile.portfolio_photos.ordered.limit(6)
  end

  def show_by_slug
    @pro_profile = ProProfile.find_by!(slug: params[:slug])
    @reviews = @pro_profile.reviews.published.recent.includes(:reviewer).limit(10)
    @services = @pro_profile.services.where("name IS NOT NULL")
    @photos = @pro_profile.portfolio_photos.ordered.limit(6)
    render :show
  end

  def new
    if Current.user.pro_profile.present?
      redirect_to edit_pro_profile_path(Current.user.pro_profile)
    else
      @pro_profile = Current.user.build_pro_profile
    end
  end

  def create
    @pro_profile = Current.user.build_pro_profile(pro_profile_params)

    if @pro_profile.save
      Current.user.update(role: :pro)
      redirect_to dashboard_path, notice: "Your pro profile has been created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if params[:inline]
      render partial: "pro_profiles/inline", layout: false
    end
  end

  def update
    if @pro_profile.update(pro_profile_params)
      redirect_to dashboard_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_pro_profile
    @pro_profile = ProProfile.find(params[:id])
  end

  def set_own_profile
    @pro_profile = Current.user.pro_profile
    redirect_to new_pro_profile_path unless @pro_profile
  end

  def pro_profile_params
    params.require(:pro_profile).permit(:business_name, :bio, :hourly_rate, :services, :location, :verified)
  end
end
