class AddEntryLocation < ActiveRecord::Migration
  def self.up
    change_table :entries do |t|
      t.references :location
    end
  end

  def self.down
    remove_column :entries, :location_id
  end
end
