class Where < ActiveRecord::Base
  has_many :tags, :as => :noun

  has_many :entries, :through => :tags #, :source => :entry, :source_type => 'Dream'
  
  has_many :users, :foreign_key => :default_location_id
end