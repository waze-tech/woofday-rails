class Pet < ApplicationRecord
  belongs_to :user

  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :species, presence: true

  scope :dogs, -> { where(species: "dog") }
  scope :cats, -> { where(species: "cat") }
  scope :alphabetically, -> { order(:name) }

  def display_name
    "#{name} the #{breed.presence || species}"
  end
end
