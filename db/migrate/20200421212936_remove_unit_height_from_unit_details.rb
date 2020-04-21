class RemoveUnitHeightFromUnitDetails < ActiveRecord::Migration[6.0]
  def change
    remove_column :unit_details, :unit_height
    remove_column :unit_details, :unit_width
    add_column :unit_details, :unit_area, :integer
    add_column :unit_details, :unit_furnishing, :string
    add_column :unit_details, :unit_availability, :string
  end
end
