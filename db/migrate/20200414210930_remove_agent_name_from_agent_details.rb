class RemoveAgentNameFromAgentDetails < ActiveRecord::Migration[6.0]
  def change
    remove_column :agent_details, :agenct_name, :string
  end
end
