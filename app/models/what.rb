class What < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
  has_many :blacklist_words
  
  MaxLength = 30
  
  validates :name,
            :presence => true,
            :uniqueness => true,
            :length => { :minimum => 3, :maximum => MaxLength }

  before_create :clean_name
  
  def self.for(word)
    what = find_or_create_by_name( clean(word) )

    what.valid? ? what : nil
  end

  # Makes any string suitable to be a what tag.
  def self.clean(word)
    word.downcase.strip.slice(0...MaxLength).gsub( /^[^[:alnum:]]+|[^[:alnum:]]+$/, '' )
  end
  
  def duplicates
    group('name').having('count(name) > 1')
  end
  
  def clean_name
    self.name = self.class.clean(self.name)
  end
end