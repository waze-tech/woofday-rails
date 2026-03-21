class Booking < ApplicationRecord
  belongs_to :pet
  belongs_to :pro_profile

  has_one :review, dependent: :destroy
  has_one :user, through: :pet

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true

  # State as records pattern (37signals style)
  # Instead of boolean flags, status tracks state
  enum :status, {
    pending: "pending",
    confirmed: "confirmed",
    in_progress: "in_progress",
    completed: "completed",
    cancelled: "cancelled"
  }, default: :pending

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
end
