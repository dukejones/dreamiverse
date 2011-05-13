class Follow < ActiveRecord::Base
  belongs_to :user
  belongs_to :following, :class_name => "User", :foreign_key => "following_id"

  validates_presence_of :user_id, :following_id
  validates_uniqueness_of :following_id, :scope => :user_id
  
  # def self.friend?(u1, u2)
  #   u1.friendship.following.find(u2) &&
  #   u2.friendship.following.find(u1)
  # end
end
