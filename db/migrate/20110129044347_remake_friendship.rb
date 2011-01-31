class RemakeFriendship < ActiveRecord::Migration
  def self.up
    drop_table :friendships

    create_table :follows do |t|
      t.integer :user_id
      t.integer :following_id
    end

    add_index :follows, [:user_id, :following_id], :unique => true
  end

  def self.down
    drop_table :follows
    
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :friend_id
      t.boolean :pending, :default => true
      t.boolean :blocked, :default => false
    end

    add_index :friendships, [:user_id, :friend_id], :unique => true
  end
end
