class AddBedsheetAttachment < ActiveRecord::Migration
  def self.up
    change_table :view_preferences do |t|
      t.string :bedsheet_attachment, :default => 'scroll'
    end
  end

  def self.down
    change_table :view_preferences do |t|
      t.remove :bedsheet_attachment
    end
  end
end
