class CreateImageEnabled < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.boolean :enabled, :default => false
    end
    
    Image.all.each {|i| i.update_attribute(:enabled, true) }
  end

  def self.down
    change_table :images do |t|
      t.remove :enabled
    end
  end
end
