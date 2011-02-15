class Tag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :noun, :polymorphic => true
end
