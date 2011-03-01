class ViewPreference < ActiveRecord::Base
  belongs_to :image
  
  belongs_to :viewable, :polymorphic => true
  
  def clone!
    self.class.create(:theme => theme, :image => image, :bedsheet_attachment => bedsheet_attachment)
  end
end
