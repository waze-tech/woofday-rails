class CreateProProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :pro_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.text :bio
      t.decimal :hourly_rate
      t.text :services
      t.string :location
      t.boolean :verified

      t.timestamps
    end
  end
end
