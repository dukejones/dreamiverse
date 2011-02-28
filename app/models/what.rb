class What < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
  has_many :blacklist_words
  
  validates :name,
            :presence => true,
            :uniqueness => true,
            :length => { :minimum => 3, :maximum => 20 }

  before_create :clean_name
  
  # def self.clean(word)
  #   # We actually want multi-word tags.
  #   # word = word[/^\S+/] # drop everything after a white space to prevent multi words
  # 
  #   # downcase and replace all non alpha num chars from begin/end
  #   # return word.downcase.gsub( /^[^[:alnum:]]+|[^[:alnum:]]+$/, '' )  
  # end
  
  scope :duplicates, group('name').having('count(name) > 1')
  
  def self.eliminate_duplicates!
    
  end
  
  def clean_name
    # self.name = self.class.clean(self.name)

    # Why not just eliminate all non-alphanumerics? Keep the spaces though.
    # This can make the name < 2 chars!
    # self.name.gsub!( /[^ ^[:alnum:]]/, '')
    self.name.downcase!
  end
end