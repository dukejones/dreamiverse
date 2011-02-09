class What < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
  
  validates_uniqueness_of :name
  #validates :name,
  #          :presence => true,
  #          :uniqueness => true
  
  before_create :clean
  
  def clean
    self.name = self.name.downcase.gsub(/[^[:alnum:]]/, '') # downcase & replace non alpha numeric chars with nothing
  end
  
  def tag_exists(name)
      w = What.find_by_name(name)
      return w.id if w
      else return nil
  end
end