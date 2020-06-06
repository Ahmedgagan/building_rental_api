class AddUiniqueToContact < ActiveRecord::Migration[6.0]
  def change
    execute "ALTER TABLE users ADD CONSTRAINT unique_detail_contact UNIQUE (contact)"    
  end
end
