class User < ActiveRecord::Base
  include Amistad::FriendModel
  has_many :authentications
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessor :password, :password_confirmation
  
  def self.create_with_omniauth(omniauth)

    user = create!(
      :name => omniauth['user_info']['name'],
      :username => omniauth['user_info']['nickname'] || omniauth['user_info']['name'].gsub(' ', '').downcase
    )
    user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
    # user.image.create!(:url => omniauth['user_info']['image'])
  end
end
