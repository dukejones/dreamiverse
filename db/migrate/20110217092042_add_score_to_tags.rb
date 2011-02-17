class AddScoreToTags < ActiveRecord::Migration
 def self.up
    add_column :tags, :score, :integer, :default => 0
    add_column :tags, :kind, :string
 end

 def self.down
    remove_column :tags, :score
    remove_column :tags, :kind
 end
end