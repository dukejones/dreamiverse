class Legacy::DreamView < Legacy::Base
  set_table_name 'dreamView'
  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}

end
