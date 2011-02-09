class CreateBlackListWords < ActiveRecord::Migration
  def self.up
    create_table :black_list_words do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :black_list_words
  end
end
