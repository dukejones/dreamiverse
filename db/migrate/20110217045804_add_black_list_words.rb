class AddBlackListWords < ActiveRecord::Migration
  def self.up
    create_table :black_list_words do |t|
     t.string :word
     t.string :kind
    end
    add_index(:black_list_words, :word)
  end

  def self.down
    drop_table :black_list_words
  end
end
