class CreateImageJoinTable < ActiveRecord::Migration
  def self.up
    create_table :entries_images, :id => false do |t|
      t.references :entry
      t.references :image
    end
  end

  def self.down
    drop_table :entries_images
  end
end
