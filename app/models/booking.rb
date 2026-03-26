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

  private

  def set_customer_from_pet
    self.customer ||= pet&.user
  end

  def notify_pro_of_request
    BookingMailer.request_received(self).deliver_later
  end
end
