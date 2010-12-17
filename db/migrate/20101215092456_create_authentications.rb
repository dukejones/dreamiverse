class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.string :provider, :uid
      t.integer :user_id
      t.timestamps
    end
    
    add_index :authentications, [:provider, :uid]
  end

  def self.down
    drop_table :authentications
  end
end
