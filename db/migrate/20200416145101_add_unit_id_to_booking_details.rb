class AddUnitIdToBookingDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :booking_details, :unit_id, :integer
  end
end
