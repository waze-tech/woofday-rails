class Pros::BlockedDatesController < ApplicationController
  before_action :require_pro_profile

  def index
    @blocked_dates = current_pro_profile.blocked_dates.upcoming
    @blocked_date = BlockedDate.new
    
    if params[:inline]
      render partial: "pros/blocked_dates/inline", layout: false
    end
  end

  def create
    @blocked_date = current_pro_profile.blocked_dates.build(blocked_date_params)
    
    if @blocked_date.save
      @blocked_dates = current_pro_profile.blocked_dates.upcoming
      @blocked_date = BlockedDate.new
      
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to pros_blocked_dates_path, notice: "Date blocked!" }
      end
    else
      redirect_to pros_blocked_dates_path, alert: @blocked_date.errors.full_messages.join(", ")
    end
  end

  def destroy
    @blocked_date = current_pro_profile.blocked_dates.find(params[:id])
    @blocked_date.destroy
    
    @blocked_dates = current_pro_profile.blocked_dates.upcoming
    @blocked_date = BlockedDate.new
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to pros_blocked_dates_path, notice: "Date unblocked." }
    end
  end

  private

  def blocked_date_params
    params.require(:blocked_date).permit(:date, :end_date, :start_time, :end_time, :block_type, :reason)
  end

  def current_pro_profile
    @current_pro_profile ||= Current.user.pro_profile
  end

  def require_pro_profile
    redirect_to root_path, alert: "You need a pro profile to access this." unless current_pro_profile
  end
end
