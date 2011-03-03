class Link < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  def self.youtube
    where("url LIKE '%youtube.com%'")
  end
  
  def youtube?
    self.url =~ /http:\/\/(?:www\.)?youtube.*/
  end
end
