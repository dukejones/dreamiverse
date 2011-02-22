class AddEntryDreamedAt < ActiveRecord::Migration
  def self.up
    add_column :entries, :dreamed_at, :datetime
  end

  def self.down
    remove_column :entries, :dreamed_at
  end
end
