class Who < ActiveRecord::Base
  has_many :tags, :as => :noun

  has_many :dreams, :through => :tags, :source => :entry, :source_type => 'Dream'
end