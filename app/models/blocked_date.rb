class BlockedDate < ApplicationRecord
  belongs_to :pro_profile

  validates :date, presence: true
  validates :date, uniqueness: { scope: :pro_profile_id, message: "is already blocked" }

  scope :upcoming, -> { where("date >= ?", Date.current).order(:date) }
  scope :past, -> { where("date < ?", Date.current).order(date: :desc) }
  scope :for_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }

  def self.blocked?(pro_profile, date)
    where(pro_profile: pro_profile, date: date).exists?
  end
end
