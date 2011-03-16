module Starlit
  def hit
    add_starlight( 1 )
    self.uniques += 1 if self[:uniques]
  end
  
  def hit!
    hit
    save!
  end
  
  def add_starlight( amount )
    self.starlight += amount
    self.cumulative_starlight += amount
  end
  
  def add_starlight!( amount )
    add_starlight( amount )
    save!
  end
  
  # entropize!
  
end