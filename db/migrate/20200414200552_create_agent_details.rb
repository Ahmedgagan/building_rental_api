class CreateAgentDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :agent_details do |t|
      t.integer :user_id
      t.string :REN
      t.string :agenct_name
      t.boolean :SPA_signed

      t.timestamps
    end
  end
end
