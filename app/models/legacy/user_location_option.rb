class Legacy::UserLocationOption < Legacy::Base
  set_table_name 'userLocationOption'

  belongs_to :user, {foreign_key: "userId", class_name: "Legacy::User"}

end
