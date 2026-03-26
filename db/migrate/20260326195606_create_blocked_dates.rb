class CreateBlockedDates < ActiveRecord::Migration[8.1]
  def change
    create_table :blocked_dates do |t|
      t.references :pro_profile, null: false, foreign_key: true
      t.date :date, null: false
      t.text :reason

      t.timestamps
    end
  end
end
