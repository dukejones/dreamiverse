def get_city_prov(id)
  w = Where.find_by_id(1)
  "#{w.city}, #{w.province}"
end