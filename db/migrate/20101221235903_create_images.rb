class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :type
      t.string :category
      t.string :genre
      t.string :title
      t.string :artist
      t.string :album
      t.string :location
      t.integer :year
      t.text :notes
      t.datetime :uploaded_at
      t.string :uploaded_by
      t.string :geotag
      t.text :tags
      t.boolean :public

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
