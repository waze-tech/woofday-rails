class Pros::BlockedDatesController < ApplicationController
  before_action :require_pro_profile

  def index
    @blocked_dates = current_pro_profile.blocked_dates.upcoming
    @blocked_date = BlockedDate.new
  end

  def create
    @blocked_date = current_pro_profile.blocked_dates.build(blocked_date_params)
    
    if @blocked_date.save
      respond_to do |format|
        format.html { redirect_to pros_blocked_dates_path, notice: "Date blocked!" }
        format.turbo_stream
      end
    else
      redirect_to pros_blocked_dates_path, alert: @blocked_date.errors.full_messages.join(", ")
    end
  end

  def destroy
    @blocked_date = current_pro_profile.blocked_dates.find(params[:id])
    @blocked_date.destroy
    
    respond_to do |format|
      format.html { redirect_to pros_blocked_dates_path, notice: "Date unblocked." }
      format.turbo_stream
    end
  end

  private

  def blocked_date_params
    params.require(:blocked_date).permit(:date, :reason)
  end

  def current_pro_profile
    @current_pro_profile ||= Current.user.pro_profile
  end

  def require_pro_profile
    redirect_to root_path, alert: "You need a pro profile to access this." unless current_pro_profile
  end
end
