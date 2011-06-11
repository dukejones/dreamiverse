module Starlit
  Entropy = 6.18
  
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
  
  def entropize!
    self.starlight *= (100 - Entropy) / 100
    save!
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def cascade_starlight_to(association)
      define_method :add_starlight do |amount|
        super amount
        obj = self.send(association)
        obj.add_starlight!(amount)
      end
    end
  end
end
