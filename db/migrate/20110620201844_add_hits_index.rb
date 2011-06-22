class AddHitsIndex < ActiveRecord::Migration
  def self.up
    add_index :hits, [:url_path, :ip_address]
  end

  def self.down
    remove_index :hits, [:url_path, :ip_address]
  end
end
