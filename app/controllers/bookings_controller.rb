class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :update]

  def index
    @upcoming = Current.user.bookings.upcoming.includes(:pet, :pro_profile)
    @past = Current.user.bookings.past.includes(:pet, :pro_profile)
  end

  def show
  end

  def new
    @pro_profile = ProProfile.find(params[:pro_profile_id])
    @pets = Current.user.pets
    @booking = Booking.new(pro_profile: @pro_profile)
  end

  def create
    @pro_profile = ProProfile.find(params[:pro_profile_id])
    @booking = Booking.new(booking_params)
    @booking.pro_profile = @pro_profile

    if @booking.save
      redirect_to booking_path(@booking), notice: "Booking request sent!"
    else
      @pets = Current.user.pets
      render :new, status: :unprocessable_entity
    end
  end

  def update
    case params[:status]
    when "confirm"
      @booking.confirm!
      notice = "Booking confirmed."
    when "complete"
      @booking.complete!
      notice = "Booking marked complete."
    when "cancel"
      @booking.cancel!
      notice = "Booking cancelled."
    end

    redirect_to dashboard_path, notice: notice
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:pet_id, :start_time, :end_time, :notes, :total_price)
  end
end
