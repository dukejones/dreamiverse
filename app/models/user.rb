class User < ActiveRecord::Base
  has_many :authentications

  has_many :entries

  has_many :hits
  
  has_many :entry_accesses

  has_one :view_preference, :as => "viewable", :dependent => :destroy
  
  # follows are the follows this user has
  # following are the users this user is following
  has_many :follows
  has_many :following, :through => :follows
  
  # followings are the follows that point to this user
  # followers are the users that follow this user
  has_many :followings, :class_name => "Follow", :foreign_key => :following_id
  has_many :followers, :through => :followings, :source => :user
  
  belongs_to :default_location, :class_name => "Where"
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me

  attr_accessor :password, :password_confirmation
  before_validation :encrypt_password
  validate :validate_password_confirmation
  validates_presence_of :username, :encrypted_password # :email
  
  before_create :create_view_preference
  
  def self.create_from_omniauth(omniauth)
    user = create!(
      :name => omniauth['user_info']['name'],
      :username => (omniauth['user_info']['nickname'] || omniauth['user_info']['name'].gsub(' ', '').downcase)
    )
    user.apply_omniauth!(omniauth)
    # user.image.create!(:url => omniauth['user_info']['image'])
  end

  def self.authenticate(auth_params)
    self.where(:encrypted_password => sha1(auth_params[:password]))
      .where(["username=? OR email=?", auth_params[:username], auth_params[:username]])
      .first
  end
  
  def apply_omniauth(omniauth)
    self.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
    self
  end

  def apply_omniauth!(omniauth)
    self.apply_omniauth(omniauth).save!
  end
  
  def friends
    following & followers
  end
  def following?(user)
    self.following.exists?(user.id)
  end
  def followed_by?(user)
    self.followers.exists?(user.id)
  end
  def friends_with?(user)
    (self.following?(user) && self.followed_by?(user)) || (self == user)
  end
  def relationship_with(other)
    if self == other
      :self
    elsif self.friends_with? other
      :friends
    elsif self.following? other
      :following
    elsif self.followed_by? other
      :followed_by
    else
      :none
    end
  end
  
  
  def encrypted_password= *args
    # raise "Can't set the encrypted password directly."
  end
  
  def can_access?(entry)
    (entry.user == self) ||
    (entry.sharing_level == Entry::Sharing[:everyone]) ||
    (entry.sharing_level == Entry::Sharing[:friends]  && friends_with?(entry.user)) ||
    (entry.sharing_level == Entry::Sharing[:users]    && entry.authorized_users.exists?(self)) ||
  end

  def create_view_preference
    return if view_preference
    self.view_preference = ViewPreference.create(theme: "light")
  end

  protected
  
  def validate_password_confirmation
    if password && (password != password_confirmation)
      errors.add :password, "should match password confirmation"
    end
  end
  
  def encrypt_password
    if password
      self[:encrypted_password] = sha1(password)
    end
  end
end
