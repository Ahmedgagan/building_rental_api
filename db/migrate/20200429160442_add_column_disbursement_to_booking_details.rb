class AddColumnDisbursementToBookingDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :booking_details, :disbursement, :boolean
    add_column :booking_details, :handover, :boolean
  end
end
