class AddFieldsToProProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :pro_profiles, :slug, :string
    add_index :pro_profiles, :slug, unique: true
    add_column :pro_profiles, :subscription_tier, :string, default: "free"
    add_column :pro_profiles, :latitude, :decimal, precision: 10, scale: 8
    add_column :pro_profiles, :longitude, :decimal, precision: 11, scale: 8
    add_column :pro_profiles, :service_radius_km, :integer, default: 10
    add_column :pro_profiles, :is_verified, :boolean, default: false
    add_column :pro_profiles, :subscription_expires_at, :datetime
  end
end
