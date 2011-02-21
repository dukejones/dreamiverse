class Legacy::Base < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "dc-alpha"
  
end