class AddCustomerAndServiceToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :customer, foreign_key: { to_table: :users }
    add_reference :bookings, :service, foreign_key: true
  end
end
