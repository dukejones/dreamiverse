class RenameBooksSharingAndImage < ActiveRecord::Migration
  def self.up
    change_table :books do |t|
      t.rename :viewing_level, :sharing_level
      t.rename :cover_image_id, :image_id
      t.remove :enabled
    end
  end

  def self.down
    change_table :books do |t|
      t.rename :sharing_level, :viewing_level
      t.rename :image_id, :cover_image_id
    end
    add_column :books, :enabled, :bit, :default => 1
  end
end
