class ViewPreference < ActiveRecord::Base
  belongs_to :bedsheet, :foreign_key => "image_id", :class_name => "Image"
  
  belongs_to :viewable, :polymorphic => true


end
