class What < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
  has_many :black_list_words
  
  validates :name,
            :presence => true,
            :uniqueness => true
 
  before_create :clean
  
  def clean
    self.name = Nephele.prep_tag(self.name)
  end
  
end