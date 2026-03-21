class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :reviewer, class_name: "User"

  has_one :pro_profile, through: :booking

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :booking_id, uniqueness: { message: "already has a review" }

  scope :recent, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(rating: :desc) }

  def stars
    "★" * rating + "☆" * (5 - rating)
  end
end
