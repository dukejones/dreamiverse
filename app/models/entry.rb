class Entry < ActiveRecord::Base
  self.inheritance_column = nil

  Sharing = {
    private:              0,
    anonymous:           50,
    users:              100,
    followers:          150,
    friends:            200,
    friends_of_friends: 300,
    everyone:           500
  }

  
  belongs_to :user

  has_many :entry_accesses
  has_many :authorized_users, :through => :entry_accesses, :source => :user

  has_many :comments
  
  has_many :tags
  has_many :whats,  :through => :tags, :source => :noun, :source_type => 'What'
  has_many :whos,   :through => :tags, :source => :noun, :source_type => 'Who'
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where'
  
  has_one :view_preference, :as => "viewable", :dependent => :destroy
  accepts_nested_attributes_for :view_preference, :update_only => true
  
  has_many :links, :as => :owner
  accepts_nested_attributes_for :links
  
  has_and_belongs_to_many :images
  
  validates_presence_of :user
  # TODO body is not blank
  
  before_save :set_sharing_level
  before_create :create_view_preference

  scope :order_by_starlight, joins(:starlights).group('starlights.id').having('max(starlights.id)').order('starlights.value DESC')
  
  scope :friends_with, -> user { 
    where( 
      user: { following: user, followers: user } 
    ).joins(:user => [:following, :followers])
  }
  
  scope :followed_by, -> user { 
    where( 
      user: { followers: user } 
    ).joins(:user => [:followers])
  }
  
  # where dream is public or i am friends with entry.user
  scope :accessible_by, -> user { 
    where( 
      (
        { sharing_level: Entry::Sharing[:everyone] } | 
        (
          { sharing_level: Entry::Sharing[:friends] } & 
          { user: { following: user, followers: user} }
        ) 
      )
    ).joins(:user.outer => [:following.outer, :followers.outer]).group(:id)
  }

  
  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end
  
  def add_what_tag(what)
    self.whats << what unless self.whats.exists? what
  end

  def sharing
    self.class::Sharing.invert[sharing_level]
  end

  def create_view_preference
    return if view_preference
    self.view_preference = user.view_preference.clone!
  end
  
  def everyone?
    sharing_level == self.class::Sharing[:everyone]
  end

  protected #######################

  def set_sharing_level
    sharing_level ||= user.default_sharing_level || self.class::Sharing[:friends]
  end

end
