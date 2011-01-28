class ImageAddAttribution < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.string :attribution
    end
  end

  def self.down
    change_table :images do |t|
      t.remove :attribution
    end
  end
end
