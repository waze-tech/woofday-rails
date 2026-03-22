class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :pro_profile, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :price
      t.string :currency
      t.string :duration
      t.string :payment_type

      t.timestamps
    end
  end
end
