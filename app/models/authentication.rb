class Authentication < ActiveRecord::Base
  validates_presence_of :user
  belongs_to :user

  def self.facebook
    where(provider: 'facebook')
  end
  
  def self.facebook?
    self.facebook.count > 0
  end
end
