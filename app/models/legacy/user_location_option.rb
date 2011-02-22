class Legacy::UserLocationOption < Legacy::Base
  set_table_name 'userLocationOption'

  belongs_to :user, {foreign_key: "userId", class_name: "Legacy::User"}
  belongs_to :location, {foreign_key: "locationId", class_name: "Legacy::Location"}
  
  def city
    location.city
  end
  def country
    location.countryIso2
  end
  def name
    title
  end
  def province
    location.region
  end
end
