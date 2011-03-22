class Where < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :entries, :through => :tags #, :source => :entry, :source_type => 'Dream'  
  has_many :users, :foreign_key => :default_location_id

  def self.for(location)
    where = Where.where(name: location['name'],city: location['city'],province: location['province'],country: location['country']).first
    where = Where.create(name: location['name'],city: location['city'],province: location['province'],country: location['country']) if where.nil?
    
   # where.valid? ? where : nil
   where
  end
  
end