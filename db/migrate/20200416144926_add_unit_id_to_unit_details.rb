class AddUnitIdToUnitDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :unit_details, :unit_id, :integer
  end
end
