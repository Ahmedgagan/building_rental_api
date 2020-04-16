class RemoveUnitIdFromUnitDetails < ActiveRecord::Migration[6.0]
  def change

    remove_column :unit_details, :unit_id, :integer
  end
end
