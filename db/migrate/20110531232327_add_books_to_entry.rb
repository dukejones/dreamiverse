class AddBooksToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :book_id, :integer
  end

  def self.down
    remove_column :entries, :book_id, :integer
  end
end
