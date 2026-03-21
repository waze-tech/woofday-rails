class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :pro_profile, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :status
      t.decimal :total_price
      t.text :notes

      t.timestamps
    end
  end
end
