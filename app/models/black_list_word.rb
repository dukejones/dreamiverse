class BlackListWord < ActiveRecord::Base
  
  validates_uniqueness_of :name 
  
  before_save :prep_tag
  
  def prep_tag
    # downcase & strip non alpha numeric chars at begin/end of string
    self.name = self.name.downcase.gsub(/^\W+|\W+$/, '') 
  end
  
end
