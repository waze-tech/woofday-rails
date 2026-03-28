# Run hourly via cron
# Checks for bookings that need completion confirmation
class BookingCompletionCheckJob < ApplicationJob
  queue_as :default

  def perform
    # Step 1: Send confirmation request to customers (2h after end_time)
    Booking.needs_completion_check.find_each do |booking|
      booking.request_completion_confirmation!
      Rails.logger.info "[BookingCompletionCheck] Requested confirmation for booking #{booking.id}"
    end

    # Step 2: Auto-complete bookings where customer ignored for 24h
    Booking.awaiting_customer_confirmation.find_each do |booking|
      booking.auto_complete!
      Rails.logger.info "[BookingCompletionCheck] Auto-completed booking #{booking.id}"
    end
  end
end
