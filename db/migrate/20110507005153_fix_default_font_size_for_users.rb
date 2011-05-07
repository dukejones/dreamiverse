class FixDefaultFontSizeForUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_font_size, :string
    remove_column :users, :font_size  # forgot the default_ for the field name...fixing 
  end

  def self.down
    remove_column :users, :default_font_size
    add_column :users, :font_size, :string  
  end
end
