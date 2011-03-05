class AllowNullLinkTitle < ActiveRecord::Migration
  def self.up
    change_column :links, :title, :string, :null => true
  end

  def self.down
    change_column :links, :title, :string, :null => false
  end
end
