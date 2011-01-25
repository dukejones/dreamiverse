class Starlight < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  def self.change(entity, amt)
    starlight = self.find_or_create_by_entity_id_and_entity_type(entity.id, entity.class.to_s)

    starlight = self.clone!(starlight) unless starlight.updated_at.to_date != Time.now.to_date

    starlight.update_attribute(:value, starlight.value + amt)
  end
  
  def self.clone!(starlight)
    self.create!(:value => starlight.value, :entity => starlight.entity)
  end
end
