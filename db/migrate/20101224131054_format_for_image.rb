class FormatForImage < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.string :format
    end
  end

  def self.down
    change_table :images do |t|
      t.remove :format
    end
  end
end
