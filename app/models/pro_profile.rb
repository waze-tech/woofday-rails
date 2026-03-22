class ProProfile < ApplicationRecord
  belongs_to :user

  has_many :services, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, through: :bookings

  validates :business_name, presence: true, on: :update
  validates :location, presence: true, on: :update

  scope :verified, -> { where(verified: true) }
  scope :setup_complete, -> { where(setup_completed: true) }
  scope :by_location, ->(loc) { where("location ILIKE ?", "%#{loc}%") }

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
