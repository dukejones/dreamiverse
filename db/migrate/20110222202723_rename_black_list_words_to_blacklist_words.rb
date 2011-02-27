class RenameBlackListWordsToBlacklistWords < ActiveRecord::Migration
  def self.up
    rename_table :black_list_words, :blacklist_words
  end

  def self.down
    rename_table :blacklist_words, :black_list_words
  end
end
