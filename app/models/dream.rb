class Dream < ActiveRecord::Base
  belongs_to :user
  has_many :tags, :as => :entry
  
  has_many :whats, :through => :tags, :source => :noun, :source_type => 'What'
  has_many :whos, :through => :tags, :source => :noun, :source_type => 'Who'
  has_many :wheres, :through => :tags, :source => :noun, :source_type => 'Where'
  
  after_create :auto_generate_tags
  
  def nouns
    whos + wheres + whats
    # tags.all(:include => :noun).map(&:noun) - seems to be slower.
  end
  
  def auto_generate_tags
    tags = body.split(/\s+/) # make tags array by splitting body up on space chars
    tags.each do |tag|
      w = What.new(name: tag)
      w.save
    end
  end
  
end
