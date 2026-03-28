class Booking < ApplicationRecord
  belongs_to :pet
  belongs_to :pro_profile
  belongs_to :customer, class_name: "User", optional: true
  belongs_to :service, optional: true

  has_one :review, dependent: :destroy
  has_one :pet_owner, through: :pet, source: :user

  validates :status, presence: true

  # State as records pattern (37signals style)
  # Instead of boolean flags, status tracks state
  enum :status, {
    pending: "pending",
    confirmed: "confirmed",
    in_progress: "in_progress",
    completed: "completed",
    cancelled: "cancelled",
    declined: "declined"
  }, default: :pending

  before_validation :set_customer_from_pet, on: :create
  after_create :notify_pro_of_request

  scope :upcoming, -> { where("start_time > ?", Time.current).order(:start_time) }
  scope :past, -> { where("end_time < ?", Time.current).order(end_time: :desc) }
  scope :active, -> { where(status: [:pending, :confirmed, :in_progress]) }
  scope :needs_completion_check, -> { 
    confirmed
      .where("end_time < ?", 2.hours.ago)
      .where(completion_requested_at: nil)
  }
  scope :awaiting_customer_confirmation, -> {
    confirmed
      .where.not(completion_requested_at: nil)
      .where("completion_requested_at < ?", 24.hours.ago)
      .where(customer_reported_issue: [nil, false])
  }

  def active?
    pending? || confirmed? || in_progress?
  end

  def duration_hours
    ((end_time - start_time) / 1.hour).round(1)
  end

  def confirm!
    update!(status: :confirmed)
    BookingMailer.confirmed(self).deliver_later
  end

  def complete!
    update!(status: :completed)
    BookingMailer.completed(self).deliver_later
    # Send review request after 2 hours
    BookingMailer.review_request(self).deliver_later(wait: 2.hours)
  end

  def cancel!(cancelled_by: "customer")
    update!(status: :cancelled)
    BookingMailer.cancelled(self, cancelled_by: cancelled_by).deliver_later
  end

  def decline!(reason = nil)
    update!(status: :declined)
    BookingMailer.declined(self).deliver_later
  end

  def request_completion_confirmation!
    update!(completion_requested_at: Time.current)
    # TODO: Send push notification to customer
    # "Did your booking with [Pro] happen?"
  end

  def customer_confirms_complete!
    update!(status: :completed)
    BookingMailer.completed(self).deliver_later
    # Review request after 2 hours
    ReviewRequestJob.set(wait: 2.hours).perform_later(self.id)
  end

  def customer_reports_issue!(reason)
    update!(customer_reported_issue: true, issue_reason: reason)
    # TODO: Notify admin for review
  end

  def auto_complete!
    # Called when customer ignores for 24h
    update!(status: :completed)
    ReviewRequestJob.set(wait: 2.hours).perform_later(self.id)
  end

  private

  def set_customer_from_pet
    self.customer ||= pet&.user
  end

  def notify_pro_of_request
    BookingMailer.request_received(self).deliver_later
  end
end
