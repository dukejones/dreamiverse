class AddEnabledToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :enabled, :bit, :default => 1
  end

  def self.down
    remove_column :books, :enabled, :bit, :default => 1
  end
end
