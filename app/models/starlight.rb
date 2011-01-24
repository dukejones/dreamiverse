class Starlight < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  def self.change(amt, entity)
    starlight = self.find_or_create_by_entity_id_and_entity_type(entity.id, entity.class.to_s)
    starlight.update_attribute(:value, starlight.value + amt)
  end
  
  
end
