class ProProfile < ApplicationRecord
  belongs_to :user

  has_many :services, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, through: :bookings
  has_many :portfolio_photos, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :blocked_dates, dependent: :destroy

  validates :business_name, presence: true, on: :update, if: :validating_profile?
  validates :location, presence: true, on: :update, if: :validating_profile?
  validates :slug, uniqueness: true, allow_blank: true

  before_save :generate_slug, if: -> { slug.blank? && business_name.present? }
  before_save :normalize_array_fields

  # Handle array params for dog_sizes and temperaments
  def dog_sizes=(value)
    super(value.is_a?(Array) ? value.reject(&:blank?).join(',') : value)
  end

  def temperaments=(value)
    super(value.is_a?(Array) ? value.reject(&:blank?).join(',') : value)
  end

  def normalize_array_fields
    self.dog_sizes = dog_sizes.to_s.split(',').map(&:strip).reject(&:blank?).join(',')
    self.temperaments = temperaments.to_s.split(',').map(&:strip).reject(&:blank?).join(',')
  end

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
    # Skip validations when just advancing the step
    update_column(:setup_step, current_setup_step + 1)
  end

  def validating_profile?
    # Only validate business_name/location when setup is complete
    setup_completed? || setup_step == 2
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

  # Check if pro is available on a specific date/time
  def available_on?(datetime)
    return false if BlockedDate.blocked?(self, datetime.to_date)
    
    day_availability = availabilities.for_day(datetime.wday)
    return false if day_availability.empty?
    
    day_availability.any? { |slot| slot.covers?(datetime) }
  end

  # Get available time slots for a date
  def available_slots_for(date)
    return [] if BlockedDate.blocked?(self, date)
    
    availabilities.for_day(date.wday).ordered
  end

  # Check if pro has any availability set
  def has_availability?
    availabilities.any?
  end
end
