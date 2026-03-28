class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :reviewer, class_name: "User"

  has_one :pro_profile, through: :booking
  has_many_attached :photos

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, length: { maximum: 1000 }
  validates :booking_id, uniqueness: { message: "already has a review" }
  validate :check_profanity, on: :create

  enum :status, {
    published: "published",
    flagged: "flagged",
    removed: "removed"
  }, default: :published

  scope :recent, -> { order(created_at: :desc) }
  scope :published, -> { where(status: :published) }
  scope :flagged, -> { where(status: :flagged) }
  scope :needs_moderation, -> { where(status: :flagged).order(flagged_at: :desc) }

  after_create :notify_pro

  PROFANITY_LIST = %w[fuck shit cunt asshole bastard bitch].freeze

  def stars
    "★" * rating + "☆" * (5 - rating)
  end

  def flag!(reason = nil)
    update!(status: :flagged, flagged_at: Time.current, flagged_reason: reason)
  end

  def unflag!
    update!(status: :published, flagged_at: nil, flagged_reason: nil)
  end

  def remove!
    update!(status: :removed)
  end

  private

  def check_profanity
    return unless content.present?
    
    words = content.downcase.split(/\W+/)
    if (words & PROFANITY_LIST).any?
      self.status = :flagged
      self.flagged_at = Time.current
      self.flagged_reason = "Auto-flagged: profanity detected"
    end
  end

  def notify_pro
    # TODO: Send push notification to Pro
    # ProNotificationJob.perform_later(booking.pro_profile, :new_review, self)
  end
end
