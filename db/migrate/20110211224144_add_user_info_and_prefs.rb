class AddUserInfoAndPrefs < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
     t.string :phone, :skype
      t.references :default_location # => Where
      t.integer :default_sharing_level, :default => Entry::Sharing[:friends]
      t.boolean :follow_authorization, :default => false
    end
    add_index :users, :seed_code
    add_index :users, :username, :unique => true

    change_table :authentications do |t|
      t.boolean :default_sharing, :default => false
    end
    add_index :authentications, :user_id
  end

  def self.down
    change_table :users do |t|
      t.remove :phone, :skype, :default_location_id, :default_sharing_level, :follow_authorization
    end
    remove_index :users, :seed_code
    remove_index :users, :username
    
    change_table :authentications do |t|
      t.remove :default_sharing
    end
    remove_index :authentications, :user_id

  end
end
