class AddSpecialtiesToPets < ActiveRecord::Migration[8.1]
  def change
    add_column :pets, :temperament, :string # calm, anxious, energetic, nervous, reactive
    add_column :pets, :is_puppy, :boolean, default: false
    add_column :pets, :is_senior, :boolean, default: false
    add_column :pets, :has_special_needs, :boolean, default: false
    add_column :pets, :special_needs_details, :text
    add_column :pets, :weight_kg, :decimal, precision: 5, scale: 2
  end
end
