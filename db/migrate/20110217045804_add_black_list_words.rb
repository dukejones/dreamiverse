class AddBlackListWords < ActiveRecord::Migration
  def self.up
    create_table :black_list_words do |t|
     t.integer :what_id
     t.string :kind
    end
  end

  def self.down
    drop_table :black_list_words
  end
end
