class CreatePortfolioPhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolio_photos do |t|
      t.references :pro_profile, null: false, foreign_key: true
      t.string :url, null: false
      t.text :caption
      t.integer :sort_order, default: 0

      t.timestamps
    end
  end
end
