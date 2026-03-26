class PortfolioPhoto < ApplicationRecord
  belongs_to :pro_profile

  validates :url, presence: true

  scope :ordered, -> { order(:sort_order, :created_at) }

  # Reorder photos
  def self.reorder!(ids)
    ids.each_with_index do |id, index|
      where(id: id).update_all(sort_order: index)
    end
  end
end
