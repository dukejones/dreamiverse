class ChangeImagesUploadedById < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.rename(:uploaded_by, :uploaded_by_id)
    end
  end

  def self.down
    change_table :images do |t|
      t.rename(:uploaded_by_id, :uploaded_by)
    end
  end
end
