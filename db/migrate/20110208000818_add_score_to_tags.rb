class AddScoreToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :score, :integer, :default => 0
  end

  def self.down
    remove_column :tags, :score
  end
end
