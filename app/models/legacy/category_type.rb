class Legacy::CategoryType < Legacy::Base
  set_table_name 'catType'
  has_many :categories, {class_name: "Legacy::Category"}
end
