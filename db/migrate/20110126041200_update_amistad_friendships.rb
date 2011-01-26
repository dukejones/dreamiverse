class UpdateAmistadFriendships < ActiveRecord::Migration
  def self.up
    change_table :friendships do |t|
      t.integer :blocker_id
      t.remove :blocked
    end
  end

  def self.down
    change_table :friendships do |t|
      t.boolean :blocked, :default => false
      t.remove :blocker_id
    end
  end
end
