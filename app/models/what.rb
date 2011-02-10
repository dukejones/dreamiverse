class What < ActiveRecord::Base
  has_many :tags, :as => :noun

  has_many :entries, :through => :tags # , :source => :entry, :source_type => 'Dream'
end