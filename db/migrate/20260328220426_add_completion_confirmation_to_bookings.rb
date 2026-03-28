class AddCompletionConfirmationToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :completion_requested_at, :datetime
    add_column :bookings, :customer_reported_issue, :boolean
    add_column :bookings, :issue_reason, :string
  end
end
