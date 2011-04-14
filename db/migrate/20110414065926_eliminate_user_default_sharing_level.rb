class EliminateUserDefaultSharingLevel < ActiveRecord::Migration
  def self.up
    change_column :users, :default_sharing_level, :integer, :default => nil
  end

  def self.down
    change_column :users, :default_sharing_level, :integer, :default => Entry::Sharing[:friends]
  end
end
