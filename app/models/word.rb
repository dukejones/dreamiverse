class Word < ActiveRecord::Base
  belongs_to :dictionary
  
  validates_presence_of :name
  validates_presence_of :dictionary_id
  
  before_create -> { self.name.downcase! }
  
end
