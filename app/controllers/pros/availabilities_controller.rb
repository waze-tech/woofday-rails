class Pros::AvailabilitiesController < ApplicationController
  before_action :require_pro_profile

  def index
    @availabilities = current_pro_profile.availabilities.ordered
    @availability = Availability.new
  end

  def create
    @availability = current_pro_profile.availabilities.build(availability_params)
    
    if @availability.save
      respond_to do |format|
        format.html { redirect_to pros_availabilities_path, notice: "Availability added!" }
        format.turbo_stream
      end
    else
      redirect_to pros_availabilities_path, alert: @availability.errors.full_messages.join(", ")
    end
  end

  def update
    @availability = current_pro_profile.availabilities.find(params[:id])
    
    if @availability.update(availability_params)
      redirect_to pros_availabilities_path, notice: "Availability updated!"
    else
      redirect_to pros_availabilities_path, alert: @availability.errors.full_messages.join(", ")
    end
  end

  def destroy
    @availability = current_pro_profile.availabilities.find(params[:id])
    @availability.destroy
    
    respond_to do |format|
      format.html { redirect_to pros_availabilities_path, notice: "Availability removed." }
      format.turbo_stream
    end
  end

  private

  def availability_params
    params.require(:availability).permit(:day_of_week, :start_time, :end_time)
  end

  def current_pro_profile
    @current_pro_profile ||= Current.user.pro_profile
  end

  def require_pro_profile
    redirect_to root_path, alert: "You need a pro profile to access this." unless current_pro_profile
  end
end
