class ChangeUserAuthLevelDefault < ActiveRecord::Migration
  def self.up
    change_column :users, :auth_level, :integer, :default => 0
  end

  def self.down
    change_column :users, :auth_level, :integer, :default => 10
  end
end
