class Pet < ApplicationRecord
  belongs_to :user

  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :species, presence: true
  validates :size, inclusion: { in: %w[small medium large giant], allow_blank: true }
  validates :temperament, inclusion: { in: %w[calm anxious energetic nervous reactive], allow_blank: true }

  # Size categories per spec
  # Small: <10kg, Medium: 10-25kg, Large: 25-45kg, Giant: >45kg
  enum :species, { dog: "dog", cat: "cat", other: "other" }, prefix: true

  before_save :auto_detect_from_breed, if: :breed_changed?
  before_save :auto_detect_from_weight, if: :weight_kg_changed?
  before_save :auto_detect_age_status, if: :age_changed?

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
    when "large" then "Large (25-45kg)"
    when "giant" then "Giant (>45kg)"
    else "Not specified"
    end
  end

  def specialty_tags
    tags = []
    tags << "#{size.titleize}" if size.present?
    tags << temperament.titleize if temperament.present?
    tags << "Puppy" if is_puppy?
    tags << "Senior" if is_senior?
    tags << "Special needs" if has_special_needs?
    tags
  end

  private

  def auto_detect_from_breed
    return unless breed.present? && species_dog?
    
    data = BreedDetector.detect_from_breed(breed)
    return if data.empty?

    # Only set if not already manually set
    self.size ||= data[:size]
    self.temperament ||= data[:temperament_hints]&.first
    self.weight_kg ||= data[:typical_weight]
  end

  def auto_detect_from_weight
    return unless weight_kg.present?
    
    detected_size = BreedDetector.detect_size_from_weight(weight_kg)
    self.size = detected_size if detected_size && size.blank?
  end

  def auto_detect_age_status
    return unless age.present?
    
    self.is_puppy = BreedDetector.is_puppy?(age) if is_puppy == false
    self.is_senior = BreedDetector.is_senior?(age, breed) if is_senior == false
  end
end
