class PublishPendingReviewsJob < ApplicationJob
  queue_as :default

  # Run this job periodically (e.g., every hour via cron)
  # It finds all pending reviews past their publish_after time
  # and publishes them (unless they've been reported)
  
  def perform
    Review.ready_to_publish.find_each do |review|
      review.publish!
      Rails.logger.info "Auto-published review ##{review.id}"
    end
  end
end
