class Legacy::UserEnvironmentOption < Legacy::Base
  set_table_name 'dreamUserEnvironmentOption'

  belongs_to :user, {foreign_key: "userId", class_name: "Legacy::User"}

end
