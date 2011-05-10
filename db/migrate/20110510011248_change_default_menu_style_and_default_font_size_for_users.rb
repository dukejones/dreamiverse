class ChangeDefaultMenuStyleAndDefaultFontSizeForUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :default_menu_style
    add_column :users, :default_menu_style, :string, :default => 'inpage'
    
    remove_column :users, :default_font_size
    add_column :users, :default_font_size, :string, :default => 'medium'
  end

  def self.down
    remove_column :users, :default_menu_style
    add_column :users, :default_menu_style, :string
    
    remove_column :users, :default_font_size
    add_column :users, :default_font_size, :string
  end
end
