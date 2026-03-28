class AddPhotoToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services, :photo_url, :string
  end
end
