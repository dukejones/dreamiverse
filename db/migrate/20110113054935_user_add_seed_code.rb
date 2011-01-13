class UserAddSeedCode < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :seed_code
    end
  end

  def self.down
    remove_column :users, :seed_code
  end
end
