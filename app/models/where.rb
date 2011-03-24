class Where < ActiveRecord::Base
  has_many :tags, :as => :noun
  has_many :entries, :through => :tags #, :source => :entry, :source_type => 'Dream'  
  has_many :users, :foreign_key => :default_loc_id

  def self.for(loc)
    w = Where.new  
    if w.enough_data?(loc)       
      where = Where.where(name: loc['name'],city: loc['city'],province: loc['province'],country: loc['country'],longitude: loc['longitude'], latitude: loc['latitude']).first
      where = Where.create(name: loc['name'],city: loc['city'],province: loc['province'],country: loc['country'],longitude: loc['longitude'], latitude: loc['latitude']) if where.nil?
      return where
    else 
      return nil
    end
  end
  
  # make sure we have atleast a name,city,province or country
  def enough_data?(loc)
    return if loc.nil?
    loc['name'].blank? && loc['city'].blank? && loc['province'].blank? && loc['country'].blank? ? nil : true
  end
  
end