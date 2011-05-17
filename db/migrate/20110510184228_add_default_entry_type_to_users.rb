class AddDefaultEntryTypeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_entry_type, :string, :default => 'dream'
  end

  def self.down
    remove_column :users, :default_entry_type
  end
end
