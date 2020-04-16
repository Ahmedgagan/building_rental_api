class FixUserDetailsColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :unit_details, :unitunit_block_name, :unit_block_name
  end
end
