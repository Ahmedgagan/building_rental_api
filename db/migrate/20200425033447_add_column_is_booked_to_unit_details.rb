class AddColumnIsBookedToUnitDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :unit_details, :is_booked, :boolean
  end
end
