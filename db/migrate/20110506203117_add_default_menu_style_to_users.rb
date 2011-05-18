class AddDefaultMenuStyleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_menu_style, :string
  end

  def self.down
    remove_column :users, :default_menu_style
  end
end
