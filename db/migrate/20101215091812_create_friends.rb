class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends do |t|
      t.integer :following_id, :follower_id

      t.timestamps
      
    end
    add_index 'friends', [:following_id, :follower_id], :unique => 'true'
  end

  def self.down
    drop_table :friends
  end
end
