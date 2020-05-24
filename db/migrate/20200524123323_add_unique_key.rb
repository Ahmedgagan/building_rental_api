class AddUniqueKey < ActiveRecord::Migration[6.0]
  def change
    execute "ALTER TABLE users ADD CONSTRAINT unique_details UNIQUE (name,email)"    
  end
end
