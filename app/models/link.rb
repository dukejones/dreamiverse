class Link < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  def youtube
    where("url LIKE '%youtube.com%'")
  end
end
