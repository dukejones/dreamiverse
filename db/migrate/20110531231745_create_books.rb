class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :title
      t.integer :user_id
      t.integer :cover_image_id
      t.string :color
      t.integer :viewing_level
      t.integer :commenting_level
      
      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end