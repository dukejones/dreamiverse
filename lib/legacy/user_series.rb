class Legacy::UserSeries < Legacy::Base
  set_table_name 'dreamUserSeries'

  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to :option, {foreign_key: "userSeriesOptionId", class_name: "Legacy::UserSeriesOption"}

end
