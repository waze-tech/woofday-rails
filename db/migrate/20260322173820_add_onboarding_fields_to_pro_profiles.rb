class AddOnboardingFieldsToProProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :pro_profiles, :phone, :string
    add_column :pro_profiles, :email, :string
    add_column :pro_profiles, :instagram, :string
    add_column :pro_profiles, :setup_step, :integer
    add_column :pro_profiles, :setup_completed, :boolean
  end
end
