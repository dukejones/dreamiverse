class AddDefaultFontSizeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :font_size, :string
  end

  def self.down
    remove_column :users, :font_size, :string
  end
end
