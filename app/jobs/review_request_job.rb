class ReviewRequestJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking&.completed?
    return if booking.review.present?

    # TODO: Send push notification
    # "How was your experience with [Pro]? Leave a review!"
    BookingMailer.review_request(booking).deliver_later
  end
end
