class CreateUnitDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :unit_details do |t|
      t.string :unit_block
      t.string :unitunit_block_name
      t.string :unit_number
      t.integer :unit_floor
      t.string :unit_price
      t.integer :unit_height
      t.integer :unit_width
      t.string :unit_type
      t.string :unit_view

      t.timestamps
    end
  end
end
