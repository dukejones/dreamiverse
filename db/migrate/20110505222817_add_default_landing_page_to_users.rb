class AddDefaultLandingPageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_landing_page, :string
  end

  def self.down
    remove_column :users, :default_landing_page
  end
end
