class CreateLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :logs do |t|
      t.string :unit_number
      t.integer :user_id
      t.string :action
      t.integer :admin_user_id
      t.string :remark

      t.timestamps
    end
  end
end
