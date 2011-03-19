class User < ActiveRecord::Base
  AuthLevel = {
    none:      0,
    basic:     10,
    moderator: 20,
    designer:  30,
    developer: 40,
    admin:     50 
  }
  
  include Starlit

  has_many :authentications
  has_many :entries
  has_many :hits
  has_many :entry_accesses
  has_one :link, :as => :owner
  accepts_nested_attributes_for :link, :update_only => true
  has_one :view_preference, :as => "viewable", :dependent => :destroy
  accepts_nested_attributes_for :view_preference, :update_only => true
  # follows are the follows this user has
  has_many :follows
  # following are the users this user is following
  has_many :following, :through => :follows
  # followings are the follows that point to this user
  has_many :followings, :class_name => "Follow", :foreign_key => :following_id
  # followers are the users that follow this user
  has_many :followers, :through => :followings, :source => :user
  belongs_to :default_location, :class_name => "Where"
  has_and_belongs_to_many :wheres
  belongs_to :image
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me

  # usernames must be lowercase
  before_create -> { username.downcase! }
  before_create :create_view_preference
  after_validation :encrypt_password

  validate :password_confirmation_matches
  validates_presence_of :username
  validates_presence_of :encrypted_password, unless: -> { password && password_confirmation }
  validates_uniqueness_of :username
  validates_length_of :username, maximum: 26, minimum: 3
  validates_uniqueness_of :email, :allow_nil => true
  validate :has_at_least_one_authentication
  
  
  # def self.order_by_starlight
  #   select('users.*').
  #   from( "( #{Starlight.current_for('User').to_sql} ) as maxstars " ).
  #   joins("JOIN starlights ON starlights.id=maxstars.maxid").
  #   joins("JOIN users ON users.id=starlights.entity_id").
  #   order('starlights.value DESC')
  # end
  def self.dreamstars
    order("starlight DESC").where("starlight > 20")
  end

  attr_accessor :password, :password_confirmation, :old_password

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
  def following_only  # following but not friends
    following - followers
  end
  
  def following?(user)
    self.following.exists?(user.id)
  end
  def followed_by?(user)
    self.followers.exists?(user.id)
  end
  # Note: you are considered to be friends with yourself.
  def friends_with?(user)
    user && (self.following?(user) && self.followed_by?(user)) || (self == user)
  end
  def relationship_with(other)
    return :none if other.nil?
    if self.friends_with? other
      :friends
    elsif self.following? other
      :following
    elsif self.followed_by? other
      :followed_by
    else
      :none
    end
  end
  
  # def encrypted_password= *args
  #   # raise "Can't set the encrypted password directly."
  # end
  # 
  def can_access?(entry)
    (entry.user == self) ||
    (entry.sharing_level == Entry::Sharing[:everyone]) ||
    (entry.sharing_level == Entry::Sharing[:friends]  && friends_with?(entry.user)) ||
    (entry.sharing_level == Entry::Sharing[:users]    && entry.authorized_users.exists?(self))
  end

  def create_view_preference
    return if view_preference
    self.view_preference = ViewPreference.create(theme: "light")
  end

  def confirmation_code
    sha1("#{self.id}-#{self.username}-#{self.created_at.to_s}")
  end
  
  # This depends on the current password, so if they change their password, the code will no longer be valid.
  def password_reset_code
    sha1("#{self.id}-#{self.username}-#{self.encrypted_password}")
  end
  
  protected

  def encrypt_password
    if password
      self[:encrypted_password] = sha1(password)
    end
  end
  
  def password_confirmation_matches
    if old_password && (sha1(old_password) != encrypted_password)
      errors.add :old_password, "does not match your current password"
    end
    if password && (password != password_confirmation)
      errors.add :password, "should match password confirmation"
    end
  end
  
  def has_at_least_one_authentication
    if (self.authentications.count == 0) && email.nil?
      errors.add :email, " must be present, or have at least one authentication."
    end
  end
  
end
