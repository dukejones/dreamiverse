class AddDefaultGenreToViewPreferences < ActiveRecord::Migration
  def self.up
    add_column :view_preferences, :default_genre, :string
  end

  def self.down
    remove_column :view_preferences, :default_genre
  end
end
