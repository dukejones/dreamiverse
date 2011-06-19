class Book < ActiveRecord::Base
  belongs_to :user
  belongs_to :image
  has_many :entries
  
  include SharingLevels
end
