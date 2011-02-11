class Entry < ActiveRecord::Base
  self.inheritance_column = nil

  Access = {
    private: 0,
    friends_of_friends: 80,
    friends: 100,
    everyone: 200
  }
  
  belongs_to :user
  has_many :tags, :as => :entry
  
  has_many :whats, :through => :tags, :source => :noun, :source_type => 'What'
  has_many :whos, :through => :tags, :source => :noun, :source_type => 'Who'
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where'
  
  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end
end
