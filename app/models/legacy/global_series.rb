class Legacy::GlobalSeries < Legacy::Base
  set_table_name 'dreamGlobalSeries'

  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to :option, {foreign_key: "dreamGlobalSeriesOptionId", class_name: "Legacy::GlobalSeriesOption"}
end
