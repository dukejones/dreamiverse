class RenameDreamsToEntries < ActiveRecord::Migration
  def self.up
    rename_table :dreams, :entries
    add_column :entries, :type, :string, :default => 'Dream'
  end

  def self.down
    remove_column :entries, :type
    rename_table :entries, :dreams
  end
end
