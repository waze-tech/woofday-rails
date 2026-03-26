class AddStatusFieldsToReviews < ActiveRecord::Migration[8.1]
  def change
    add_column :reviews, :status, :string, default: "pending"
    add_column :reviews, :publish_after, :datetime
    add_column :reviews, :published_at, :datetime
  end
end
