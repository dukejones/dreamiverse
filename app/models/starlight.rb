class Starlight < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  def self.change(entity, amt)
    finder_hash = {:entity_id => entity.id, :entity_type => entity.class.to_s}
    starlight = self.where(finder_hash).last
    starlight = self.create!(finder_hash) unless starlight
    starlight = self.clone!(starlight) unless (starlight.updated_at.to_date == Time.now.to_date)

    starlight.update_attribute(:value, starlight.value + amt)
  end
  
  def self.clone!(starlight)
    Rails.logger.info "Cloning starlight: #{starlight.id}"
    self.create!(:value => starlight.value, :entity => starlight.entity)
  end
  
  def self.entropize!
    # group most recent starlight for every entity
  end
end
