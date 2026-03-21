class ReviewsController < ApplicationController
  def new
    @booking = Booking.find(params[:booking_id])
    @review = @booking.build_review(reviewer: Current.user)
  end

  def create
    @booking = Booking.find(params[:booking_id])
    @review = @booking.build_review(review_params)
    @review.reviewer = Current.user

    if @review.save
      redirect_to dashboard_path, notice: "Thanks for your review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
