class Pet < ApplicationRecord
  belongs_to :user

  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :species, presence: true
  validates :size, inclusion: { in: %w[small medium large], allow_blank: true }

  # Size categories per spec
  # Small: <10kg, Medium: 10-25kg, Large: >25kg
  enum :species, { dog: "dog", cat: "cat", other: "other" }, prefix: true

  scope :dogs, -> { where(species: "dog") }
  scope :cats, -> { where(species: "cat") }
  scope :alphabetically, -> { order(:name) }
  scope :small, -> { where(size: "small") }
  scope :medium, -> { where(size: "medium") }
  scope :large, -> { where(size: "large") }

  def display_name
    "#{name} the #{breed.presence || species.humanize}"
  end

  def size_label
    case size
    when "small" then "Small (<10kg)"
    when "medium" then "Medium (10-25kg)"
    when "large" then "Large (>25kg)"
    else "Not specified"
    end
  end
end
