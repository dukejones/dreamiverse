class Book < ActiveRecord::Base
  belongs_to :user
  belongs_to :image
  has_many :entries
  
  include SharingLevels
  
  after_initialize :set_defaults
  
  protected
  
  def set_defaults
    self.color = 'blue'
  end
end
