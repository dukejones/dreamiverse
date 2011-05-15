class ViewPreference < ActiveRecord::Base
  belongs_to :image
  
  belongs_to :viewable, :polymorphic => true
  
  validates_inclusion_of :menu_style, :in => %w( float inpage )
  validates_inclusion_of :font_size, :in => %w( small medium large )

  def clone!
    self.class.create(:theme => theme, :image => image, :bedsheet_attachment => bedsheet_attachment)
  end
end
