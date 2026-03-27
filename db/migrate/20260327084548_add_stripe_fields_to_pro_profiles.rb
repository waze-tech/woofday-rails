class AddStripeFieldsToProProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :pro_profiles, :stripe_customer_id, :string
    add_column :pro_profiles, :stripe_subscription_id, :string
    
    add_index :pro_profiles, :stripe_customer_id, unique: true, where: "stripe_customer_id IS NOT NULL"
    add_index :pro_profiles, :stripe_subscription_id, unique: true, where: "stripe_subscription_id IS NOT NULL"
  end
end
