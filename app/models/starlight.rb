class Starlight < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  def self.add(amt, entity)
    
  end
end
