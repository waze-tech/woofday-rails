class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :reviewer, class_name: "User"

  has_one :pro_profile, through: :booking

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 500 }
  validates :booking_id, uniqueness: { message: "already has a review" }

  # Review moderation status
  enum :status, {
    pending: "pending",
    published: "published",
    reported: "reported",
    rejected: "rejected"
  }, default: :pending

  before_create :set_publish_after

  scope :recent, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(rating: :desc) }
  scope :published, -> { where(status: :published) }
  scope :ready_to_publish, -> { pending.where("publish_after <= ?", Time.current) }

  def stars
    "★" * rating + "☆" * (5 - rating)
  end

  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def report!
    update!(status: :reported)
  end

  def reject!
    update!(status: :rejected)
  end

  def publishable?
    pending? && publish_after <= Time.current
  end

  private

  def set_publish_after
    self.publish_after = 24.hours.from_now
  end
end
