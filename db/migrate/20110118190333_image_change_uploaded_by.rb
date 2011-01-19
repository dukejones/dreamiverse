class ImageChangeUploadedBy < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.change :uploaded_by, :integer
      t.remove :uploaded_at
      t.change :format, :string, :limit => 10
    end
  end

  def self.down
    change_table :images do |t|
      t.change :uploaded_by, :string
      t.column :uploaded_at, :datetime
      t.change :format, :string
    end
  end
end
