class AddUserWebsite < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.references :link
    end
    # authlevel
    # ubiquity
  end

  def self.down
    remove_column :users, :link_id
  end
end
