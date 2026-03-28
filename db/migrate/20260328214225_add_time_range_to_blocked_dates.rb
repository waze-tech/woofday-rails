class AddTimeRangeToBlockedDates < ActiveRecord::Migration[8.1]
  def change
    add_column :blocked_dates, :end_date, :date
    add_column :blocked_dates, :start_time, :time
    add_column :blocked_dates, :end_time, :time
    add_column :blocked_dates, :block_type, :integer, default: 0
  end
end
