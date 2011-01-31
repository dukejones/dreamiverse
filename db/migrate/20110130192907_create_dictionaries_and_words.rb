class CreateDictionariesAndWords < ActiveRecord::Migration
  def self.up
    create_table :dictionaries do |t|
      t.string :name
      t.string :attribution
      t.timestamps
    end

    create_table :words do |t|
      t.string :name
      t.text :definition
      t.string :attribution
      t.references :dictionary
    end
    add_index :words, :name
  end

  def self.down
    drop_table :dictionaries
    drop_table :words
  end
end
