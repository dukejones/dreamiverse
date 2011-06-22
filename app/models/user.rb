class User < ActiveRecord::Base
  AuthLevel = {
    none:      0,
    basic:     1,
    moderator: 2,
    designer:  3,
    developer: 4,
    admin:     5 
  }
  
  include Starlit

  serialize :stream_filter
  
  has_many :authentications
  has_many :entries, :dependent => :destroy
  has_many :hits
  has_many :entry_accesses
  has_one :link, :as => :owner
  accepts_nested_attributes_for :link, :update_only => true, :reject_if => :all_blank
  has_one :view_preference, :as => "viewable", :dependent => :destroy
  accepts_nested_attributes_for :view_preference, :update_only => true
  # follows are the follows this user has
  has_many :follows, :dependent => :destroy
  # following are the users this user is following
  has_many :following, :through => :follows
  # followings are the follows that point to this user
  has_many :followings, :class_name => "Follow", :foreign_key => :following_id, :dependent => :destroy
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

  before_create :create_view_preference
  before_create :set_defaults
  before_validation(:on => :create) do
    username.strip!
    username.downcase! 
    email.strip!
    email.downcase!
  end  
  after_validation :encrypt_password

  validates_presence_of :encrypted_password, unless: -> { password && password_confirmation }
  validate :password_confirmation_matches
  validates_presence_of :username
  # (db constraint) validates_uniqueness_of :username
  validates_length_of :username, maximum: 26, minimum: 3
  validates_format_of :username, :without => /[^a-zA-Z\d*_\-]/, 
    :message => "contains invalid characters (only letters, numbers, underscores, dashes and asterix's allowed in usernames)"
  validates_presence_of :encrypted_password, unless: -> { password && password_confirmation }
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create  

  validates_inclusion_of :default_entry_type, :in => %w( dream vision experience article journal )
  validates_inclusion_of :default_landing_page, :in => %w( stream home today )
  
  def self.dreamstars
    order("starlight DESC").where("starlight > 50")
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
      .where("username=:username OR email=:username", {username: auth_params[:username]})
      .first
  end

  def self.authenticate_from_remember_me_cookie(cookie_value)
    user_id, password_hash = cookie_value.split('::')
    u = find_by_id(user_id)
    u && password_hash == u.encrypted_password ? u : nil
  end
  
  def remember_me_cookie_value
    [self.id, self.encrypted_password].join('::')
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
    user && (self.following?(user) && self.followed_by?(user))
  end
  def relationship_with(other)
    return :none if other.nil?
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
  
  def can_access?(entry)
    (entry.user == self) ||
    (entry.sharing_level == Entry::Sharing[:everyone]) ||
    (entry.sharing_level == Entry::Sharing[:friends]  && friends_with?(entry.user)) ||
    (entry.sharing_level == Entry::Sharing[:followers] && following?(entry.user)) ||
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
  
  def update_stream_filter(filters)
    if filters.kind_of?(Hash)
      # only the keys which we are storing as defaults
      self.stream_filter ||= {}
      self.stream_filter[:type] = filters[:type] if filters.has_key?(:type)
      self.stream_filter[:users] = filters[:users] if filters.has_key?(:users)
      self.save
    else
      filters = self.stream_filter
    end
    filters || {}
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
  
  # def has_at_least_one_authentication
  #   if (self.authentications.count == 0) && email.nil?
  #     errors.add :email, " must be present, or have at least one authentication."
  #   end
  # end
  
  def set_defaults
    self.auth_level ||= AuthLevel[:basic]
    # TODO: Make this default to :followers
    self.default_sharing_level ||= Entry::Sharing[:everyone]
    self.default_landing_page ||= 'stream'
    self.default_entry_type ||= 'dream'
    self.stream_filter ||= {}
  end
  
end
