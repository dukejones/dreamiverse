def find_state_prov(id = 1)
  w = Where.find_by_id(1)
  "#{w.city}, #{w.province}"
end