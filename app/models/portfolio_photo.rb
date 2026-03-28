class PortfolioPhoto < ApplicationRecord
  belongs_to :pro_profile
  
  has_one_attached :image

  validates :url, presence: true, unless: -> { image.attached? }
  validate :url_or_image_present

  scope :ordered, -> { order(:sort_order, :created_at) }

  # Reorder photos
  def self.reorder!(ids)
    ids.each_with_index do |id, index|
      where(id: id).update_all(sort_order: index)
    end
  end

  def display_url
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      url
    end
  end

  private

  def url_or_image_present
    unless url.present? || image.attached?
      errors.add(:base, "Either an image file or URL is required")
    end
  end
end
