class CreateEmotions < ActiveRecord::Migration
  def self.up
    create_table :emotions do |t|
      t.string :name
    end
    
    change_table :tags do |t|
      t.integer :intensity
    end
  end

  def self.down
    drop_table :emotions
    remove_column :tags, :intensity
  end
end
