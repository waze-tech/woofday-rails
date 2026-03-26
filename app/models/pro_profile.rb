class ProProfile < ApplicationRecord
  belongs_to :user

  has_many :services, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, through: :bookings

  validates :business_name, presence: true, on: :update
  validates :location, presence: true, on: :update
  validates :slug, uniqueness: true, allow_blank: true

  before_save :generate_slug, if: -> { slug.blank? && business_name.present? }

  # Subscription tiers
  enum :subscription_tier, { free: "free", pro: "pro" }, default: :free, prefix: :tier

  scope :verified, -> { where(is_verified: true) }
  scope :setup_complete, -> { where(setup_completed: true) }
  scope :by_location, ->(loc) { where("location ILIKE ?", "%#{loc}%") }
  scope :pro_tier, -> { where(subscription_tier: "pro") }

  def generate_slug
    base_slug = business_name.parameterize
    slug_candidate = base_slug
    counter = 1

    while ProProfile.where(slug: slug_candidate).where.not(id: id).exists?
      slug_candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug_candidate
  end

  def pro_subscription?
    tier_pro? && (subscription_expires_at.nil? || subscription_expires_at > Time.current)
  end

  SETUP_STEPS = {
    instagram: 1,
    profile: 2,
    services: 3
  }.freeze

  def setup_complete?
    setup_completed?
  end

  def current_setup_step
    setup_step || 1
  end

  def advance_setup!
    update!(setup_step: current_setup_step + 1)
  end

  def complete_setup!
    update!(setup_completed: true, setup_step: 3)
  end

  def average_rating
    reviews.average(:rating)&.round(1) || 0
  end

  def total_reviews
    reviews.count
  end
end
