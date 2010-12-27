class AlterUserAddEmailPassword < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :encrypted_password
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :encrypted_password
    end
  end
end
