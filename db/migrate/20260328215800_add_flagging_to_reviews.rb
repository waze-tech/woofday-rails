class AddFlaggingToReviews < ActiveRecord::Migration[8.1]
  def change
    add_column :reviews, :flagged_at, :datetime
    add_column :reviews, :flagged_reason, :string
  end
end
