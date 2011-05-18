class AddDefaultStreamEntryTypeFilterAndDefaultStreamUsersFilterToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_stream_entry_type_filter, :string, :default => 'all entries'
    add_column :users, :default_stream_users_filter, :string, :default => 'all users'
  end

  def self.down
    remove_column :users, :default_stream_entry_type_filter
    remove_column :users, :default_stream_users_filter
  end
end
