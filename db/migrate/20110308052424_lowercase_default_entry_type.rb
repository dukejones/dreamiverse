class LowercaseDefaultEntryType < ActiveRecord::Migration
  def self.up
    change_column :entries, :type, :string, :default => "dream"
  end

  def self.down
    change_column :entries, :type, :string, :default => "Dream"
  end
end
