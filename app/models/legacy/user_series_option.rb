class Legacy::UserSeriesOption < Legacy::Base
  set_table_name 'userSeriesOption'
  belongs_to :user, {foreign_key: "userId", class_name: "Legacy::User"}

end
