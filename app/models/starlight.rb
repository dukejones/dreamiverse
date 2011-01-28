class Starlight < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  scope :all_for, lambda {|e| where(entity_id: e.id, entity_type: e.class.to_s) }
  
  def self.for(entity)
    starlight = all_for(entity).last
    starlight = self.create!(entity: entity) unless starlight
    starlight = starlight.clone! unless (starlight.updated_at.to_date == Time.now.to_date)
    starlight
  end
  
  def self.all_entities
    Starlight.group("entity_id,entity_type").select("entity_id,entity_type").map(&:entity)    
  end

  # TODO: deprecate
  def self.change(entity, amt)
    starlight = self.for(entity)
    starlight.change(amt)
  end
  
  def clone!
    Rails.logger.info "Cloning starlight: #{self.id}"
    self.class.create!(:value => self.value, :entity => self.entity)
  end
  
  def change(amt)
    value += amt
    save
  end
  
  def entropize!
    self.value *= 0.9
    self.save
  end
end
