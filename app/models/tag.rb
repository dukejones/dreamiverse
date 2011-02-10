class Tag < ActiveRecord::Base
  belongs_to :entry # , :polymorphic => true
  belongs_to :noun, :polymorphic => true
end
