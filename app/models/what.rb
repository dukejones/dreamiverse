class What < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
  
  validates_uniqueness_of :name
  #validates :name,
  #          :presence => true,
  #          :uniqueness => true
 #
  before_create :clean
  
  def clean
    # downcase & strip non alpha numeric chars at begin/end of string
    self.name = self.name.downcase.gsub(/^\W+|\W+$/, '')
  end
  
end