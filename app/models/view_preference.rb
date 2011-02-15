class ViewPreference < ActiveRecord::Base
  belongs_to :image
  
  belongs_to :viewable, :polymorphic => true
  
  def clone!
    self.class.create(:theme => theme, :bedsheet => bedsheet)
  end
end
