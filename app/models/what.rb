class What < ActiveRecord::Base
  has_many :tags, :as => :noun

  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
  
  before_create :clean
  
  def clean
    self.name = self.name.gsub(/[^[:alnum:]]/, '') # replace non alpha numeric chars wiht nothing
  end
end