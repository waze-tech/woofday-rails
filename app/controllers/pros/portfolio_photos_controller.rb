class Pros::PortfolioPhotosController < ApplicationController
  before_action :require_pro_profile

  def index
    @photos = current_pro_profile.portfolio_photos.ordered
    
    if params[:inline]
      render partial: "pros/portfolio_photos/inline", layout: false
    end
  end

  def create
    @photo = current_pro_profile.portfolio_photos.build(photo_params)
    
    if @photo.save
      respond_to do |format|
        format.html { redirect_to pros_portfolio_photos_path, notice: "Photo added!" }
        format.turbo_stream
      end
    else
      redirect_to pros_portfolio_photos_path, alert: @photo.errors.full_messages.join(", ")
    end
  end

  def destroy
    @photo = current_pro_profile.portfolio_photos.find(params[:id])
    @photo.destroy
    
    respond_to do |format|
      format.html { redirect_to pros_portfolio_photos_path, notice: "Photo removed." }
      format.turbo_stream
    end
  end

  def reorder
    params[:photo_ids].each_with_index do |id, index|
      current_pro_profile.portfolio_photos.where(id: id).update_all(sort_order: index)
    end
    
    head :ok
  end

  private

  def photo_params
    params.require(:portfolio_photo).permit(:url, :caption, :image)
  end

  def current_pro_profile
    @current_pro_profile ||= Current.user.pro_profile
  end

  def require_pro_profile
    redirect_to root_path, alert: "You need a pro profile to access this." unless current_pro_profile
  end
end
