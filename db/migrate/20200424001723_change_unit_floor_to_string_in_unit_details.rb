class ChangeUnitFloorToStringInUnitDetails < ActiveRecord::Migration[6.0]
  def change
    change_column :unit_details, :unit_floor, :string
  end
end
