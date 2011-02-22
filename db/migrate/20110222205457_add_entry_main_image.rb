class AddEntryMainImage < ActiveRecord::Migration
  def self.up
    change_table :entries do |t|
      t.references :main_image
    end
  end

  def self.down
    remove_column :entries, :main_image_id
  end
end
