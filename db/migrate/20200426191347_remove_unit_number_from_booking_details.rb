class RemoveUnitNumberFromBookingDetails < ActiveRecord::Migration[6.0]
  def change
    remove_column :booking_details, :unit_number
  end
end
