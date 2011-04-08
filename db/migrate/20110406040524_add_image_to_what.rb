class AddImageToWhat < ActiveRecord::Migration
  def self.up
    add_column :whats, :image_id, :integer   
  end

  def self.down
    remove_column :whats, :image_id
  end
end
