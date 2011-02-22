class AddUserUbiquityAuthLevel < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :ubiquity, :default => false, :null => false
      t.integer :auth_level, :default => User::AuthLevel[:basic]
    end
  end

  def self.down
    remove_column :users, :ubiquity
    remove_column :users, :auth_level
  end
end
