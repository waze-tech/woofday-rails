class AddSizeToPets < ActiveRecord::Migration[8.1]
  def change
    add_column :pets, :size, :string
    add_column :pets, :photo_url, :string
  end
end
