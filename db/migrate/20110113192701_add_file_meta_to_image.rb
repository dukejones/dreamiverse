class AddFileMetaToImage < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.integer :size # bytes
      t.integer :width
      t.integer :height
      t.string :original_filename
    end
  end

  def self.down
    change_table :images do |t|
      t.remove :size
      t.remove :width
      t.remove :height
      t.remove :original_filename
    end
  end
end
