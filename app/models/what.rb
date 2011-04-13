class What < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
  has_many :blacklist_words
  has_many :dictionary_words, {class_name: 'Word', primary_key: :name, foreign_key: :name}
  belongs_to :image
  
  MaxLength = 30

  include Starlit
  
  validates :name,
            :presence => true,
            :uniqueness => true,
            :length => { :minimum => 2, :maximum => MaxLength }

  before_create :clean_name
  
  def self.for(word)
    what = find_or_create_by_name( clean(word) )

    what.valid? ? what : nil
  end

  # Makes any string suitable to be a what tag.
  def self.clean(word)
    word.downcase.strip.gsub( /^[^[:alnum:]]+|[^[:alnum:]]+$/, '' ).slice(0...MaxLength)
  end
  
  def self.duplicates
    group('name').having('count(name) > 1')
  end
  
  def clean_name
    self.name = self.class.clean(self.name)
  end
end