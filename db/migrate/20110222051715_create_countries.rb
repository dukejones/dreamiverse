class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :iso2, :limit => 2
      t.string :iso3, :limit => 3
      t.string :name
    end
    add_index :countries, :iso2
  end

  def self.down
    drop_table :countries
  end
end
