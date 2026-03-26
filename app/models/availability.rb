class Availability < ApplicationRecord
  belongs_to :pro_profile

  # Day of week: 0 = Sunday, 6 = Saturday
  DAYS = {
    0 => "Sunday",
    1 => "Monday",
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6 => "Saturday"
  }.freeze

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  scope :for_day, ->(day) { where(day_of_week: day) }
  scope :ordered, -> { order(:day_of_week, :start_time) }

  def day_name
    DAYS[day_of_week]
  end

  def time_range
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end

  # Check if a given time falls within this availability slot
  def covers?(time)
    time_only = time.strftime("%H:%M:%S")
    start_str = start_time.strftime("%H:%M:%S")
    end_str = end_time.strftime("%H:%M:%S")
    time_only >= start_str && time_only < end_str
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
