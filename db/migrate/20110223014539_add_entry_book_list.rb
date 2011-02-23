class AddEntryBookList < ActiveRecord::Migration
  # This is a temporary field to be exported to the One True Book Model once it is in place!
  # And then Destroyed!
  def self.up
    change_table :entries do |t|
      t.string :book_list
    end
  end

  def self.down
    remove_column :entries, :book_list
  end
end
