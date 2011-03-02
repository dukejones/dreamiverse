class Link < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  scope :youtube, where("url LIKE '%youtube.com%'")
end
