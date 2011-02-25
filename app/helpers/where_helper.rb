module WhereHelper
  def get_city_prov(id)
    w = Where.find_by_id(id)
    "#{w.city}, #{w.province}"
  end
end