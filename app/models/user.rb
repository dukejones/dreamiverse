class User < ActiveRecord::Base
  #has_many :follower_friends, :class_name => "Friend", :primary_key => :follower_id, :foreign_key => :following_id
  #has_many :following_friends, :class_name => "Friend", :primary_key => :following_id, :foreign_key => :follower_id
  #has_many :followers, :through => :friend
  #has_many :following, :through => :friend
  
  #has_many :friends
  
#  sql = %{
#    select * from users
#    join friends on follower_id=#{me}
#    join friends on followed_id=#{me}
#  }
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me
end
