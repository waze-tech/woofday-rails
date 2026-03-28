class BlockedDate < ApplicationRecord
  belongs_to :pro_profile

  enum :block_type, { full_day: 0, time_slot: 1, date_range: 2 }

  validates :date, presence: true
  validates :end_date, presence: true, if: :date_range?
  validates :start_time, :end_time, presence: true, if: :time_slot?
  validate :end_date_after_start_date, if: :date_range?
  validate :end_time_after_start_time, if: :time_slot?

  scope :upcoming, -> { where("date >= ? OR end_date >= ?", Date.current, Date.current).order(:date) }
  scope :past, -> { where("COALESCE(end_date, date) < ?", Date.current).order(date: :desc) }
  scope :for_month, ->(date) { 
    where("date <= ? AND COALESCE(end_date, date) >= ?", date.end_of_month, date.beginning_of_month) 
  }

  def self.blocked?(pro_profile, check_date, check_time = nil)
    blocks = where(pro_profile: pro_profile)
    
    blocks.any? do |block|
      case block.block_type
      when "full_day"
        block.date == check_date
      when "time_slot"
        block.date == check_date && check_time && 
          check_time >= block.start_time && check_time < block.end_time
      when "date_range"
        check_date >= block.date && check_date <= block.end_date
      end
    end
  end

  def display_text
    case block_type
    when "full_day"
      date.strftime("%b %d, %Y")
    when "time_slot"
      "#{date.strftime("%b %d")} #{start_time.strftime("%H:%M")}–#{end_time.strftime("%H:%M")}"
    when "date_range"
      "#{date.strftime("%b %d")} – #{end_date.strftime("%b %d, %Y")}"
    end
  end

  private

  def end_date_after_start_date
    return unless date && end_date
    errors.add(:end_date, "must be after start date") if end_date < date
  end

  def end_time_after_start_time
    return unless start_time && end_time
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
end
