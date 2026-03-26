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

  scope :upcoming, -> { where("start_time > ?", Time.current).order(:start_time) }
  scope :past, -> { where("end_time < ?", Time.current).order(end_time: :desc) }
  scope :active, -> { where(status: [:pending, :confirmed, :in_progress]) }

  def duration_hours
    ((end_time - start_time) / 1.hour).round(1)
  end

  def confirm!
    update!(status: :confirmed)
  end

  def complete!
    update!(status: :completed)
  end

  def cancel!
    update!(status: :cancelled)
  end

  def decline!(reason = nil)
    update!(status: :declined)
  end

  private

  def set_customer_from_pet
    self.customer ||= pet&.user
  end
end
