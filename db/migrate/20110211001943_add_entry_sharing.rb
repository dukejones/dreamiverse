class AddEntrySharing < ActiveRecord::Migration
  def self.up
    add_column :entries, :sharing_level, :integer
    create_table :entry_accesses do |t|
      t.references :user
      t.references :entry
      t.integer :level, :default => EntryAccess::Level[:read]
    end
  end

  def self.down
    remove_column :entries, :sharing_level
    remove_table :entry_accesses
  end
end
