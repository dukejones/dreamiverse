class DefaultUserDefaultSettings < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.remove :default_landing_page, :default_entry_type

      t.string :default_landing_page, :default => 'stream'
      t.string :default_entry_type, :default => 'dream'
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :default_landing_page, :default_entry_type

      t.string :default_landing_page, :default => nil
      t.string :default_entry_type, :default => nil
    end
  end
end
