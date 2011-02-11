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
  
  has_many :tags, :as => :entry
  has_many :whats, :through => :tags, :source => :noun, :source_type => 'What'
  has_many :whos, :through => :tags, :source => :noun, :source_type => 'Who'
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where'
  
  validates_presence_of :user
  
  before_save :set_sharing_level
  
  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end

  protected #######################

  def set_sharing_level
    # sharing_level ||= user.default_sharing_level
    # sharing_level ||= self::Sharing[:everyone]
  end
end
