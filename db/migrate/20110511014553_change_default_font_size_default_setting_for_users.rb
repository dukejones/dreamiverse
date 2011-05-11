class ChangeDefaultFontSizeDefaultSettingForUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :default_font_size
    add_column :users, :default_font_size, :string, :default => 'fontMedium'
  end

  def self.down
    remove_column :users, :default_font_size
    add_column :users, :default_font_size, :string, :default => 'medium'
  end
end
