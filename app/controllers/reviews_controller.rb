class ReviewsController < ApplicationController
  before_action :set_booking, only: [:new, :create]

  def new
    redirect_to dashboard_path, alert: "Already reviewed" if @booking.review.present?
    @review = @booking.build_review(reviewer: Current.user)
  end

  def create
    @review = @booking.build_review(review_params)
    @review.reviewer = Current.user

    if @review.save
      redirect_to dashboard_path, notice: "Thanks for your review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Pro flags a review
  def flag
    @review = Review.find(params[:id])
    
    unless @review.booking.pro_profile.user == Current.user
      return redirect_to dashboard_path, alert: "Not authorized"
    end

    @review.flag!(params[:reason])
    redirect_back fallback_location: dashboard_path, notice: "Review flagged for moderation"
  end

  private

  def set_booking
    @booking = Current.user.bookings.completed.find(params[:booking_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "Booking not found or not completed"
  end

  def review_params
    params.require(:review).permit(:rating, :content, photos: [])
  end
end
