class Dream < ActiveRecord::Base
  belongs_to :user
  has_many :tags, :as => :entry
  
  has_many :whats, :through => :tags, :source => :noun, :source_type => 'What'
  has_many :whos, :through => :tags, :source => :noun, :source_type => 'Who'
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where'
  
  after_create :process_tags
  
  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end
  
  def process_tags
    n = Nephele.new
    n.process_single_entry_tags(self)
  end
  
end
