class ProProfile < ApplicationRecord
  belongs_to :user

  has_many :bookings, dependent: :destroy
  has_many :reviews, through: :bookings

  validates :business_name, presence: true
  validates :hourly_rate, presence: true, numericality: { greater_than: 0 }

  scope :verified, -> { where(verified: true) }
  scope :by_location, ->(loc) { where("location ILIKE ?", "%#{loc}%") }
  scope :by_service, ->(service) { where("services ILIKE ?", "%#{service}%") }

  def average_rating
    reviews.average(:rating)&.round(1) || 0
  end

  def total_reviews
    reviews.count
  end

  def available_services
    services.to_s.split(",").map(&:strip)
  end
end
