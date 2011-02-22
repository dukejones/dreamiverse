class Legacy::UserEnvironment < Legacy::Base
  set_table_name 'dreamUserEnvironment'

  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to :option, {foreign_key: "userEnvironmentOptionId", class_name: "Legacy::UserEnvironmentOption"}
end
