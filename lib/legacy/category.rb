class Legacy::Category < Legacy::Base
  set_table_name 'cat'

  belongs_to 'type', {foreign_key: "catTypeId", class_name: "Legacy::CategoryType"}
end
