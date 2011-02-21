class Legacy::Comment < Legacy::Base
  set_table_name 'dreamComment'

  belongs_to 'dream', {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to 'user', {foreign_key: 'userId', class_name: "Legacy::User"}
end
