class Entry < ActiveRecord::Base
  self.inheritance_column = nil

  Sharing = {
    private:              0,
    anonymous:           50,
    users:              100,
    friends:            200,
    friends_of_friends: 300,
    everyone:           500
  }
  
  belongs_to :user

  has_many :entry_accesses
  has_many :authorized_users, :through => :entry_accesses, :source => :user
  
  has_many :tags
  has_many :whats,  :through => :tags, :source => :noun, :source_type => 'What'
  has_many :whos,   :through => :tags, :source => :noun, :source_type => 'Who'
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where'
  
  has_one :view_preference, :as => "viewable", :dependent => :destroy
  
  validates_presence_of :user
  
  before_save :set_sharing_level
  before_create :create_view_preference
  before_update :delete_tags
  
  after_save :process_tags
  
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

  # clear out existing tags/scores so they can be repopulated on save
  def delete_tags
    #Nephele.delete_scores(self.id)
    n = Nephele.new
    n.delete_scores(self.id)
  end

  def process_tags
    #Nephele::process_single_entry_tags(self) 
    n = Nephele.new
    n.process_single_entry_tags(self)
  end
       
  protected #######################

  def set_sharing_level
    # sharing_level ||= user.default_sharing_level
    # sharing_level ||= self::Sharing[:everyone]
  end

end
