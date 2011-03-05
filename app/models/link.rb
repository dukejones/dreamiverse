class Link < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  validates_presence_of :url
  
  def self.youtube
    where("url LIKE '%youtube.com%'")
  end
  
  def youtube?
    self.url =~ /http:\/\/(?:www\.)?youtube.*/
  end
end
