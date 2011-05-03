class AddNewCommentCountToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :new_comment_count, :integer, :default => 0
  end

  def self.down
    remove_column :entries, :new_comment_count
  end
end
