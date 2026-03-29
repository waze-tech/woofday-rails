class AddSpecialtiesToProProfiles < ActiveRecord::Migration[8.1]
  def change
    # Stored as comma-separated values or JSON array
    add_column :pro_profiles, :dog_sizes, :string, default: "" # small, medium, large, giant
    add_column :pro_profiles, :temperaments, :string, default: "" # calm, anxious, energetic, aggressive, nervous
    add_column :pro_profiles, :breed_specialties, :text # free text for specific breeds
    add_column :pro_profiles, :accepts_puppies, :boolean, default: true
    add_column :pro_profiles, :accepts_senior_dogs, :boolean, default: true
    add_column :pro_profiles, :accepts_special_needs, :boolean, default: false
    add_column :pro_profiles, :home_type, :string # apartment, house, studio
    add_column :pro_profiles, :has_garden, :boolean, default: false
    add_column :pro_profiles, :other_pets, :string # none, dogs, cats, other
    add_column :pro_profiles, :smoking_home, :boolean, default: false
  end
end
