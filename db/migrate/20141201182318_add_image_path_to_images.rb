class AddImagePathToImages < ActiveRecord::Migration
  def change
    add_column :images, :image_path, :string
  end
end
