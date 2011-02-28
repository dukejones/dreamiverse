class Legacy::GlobalSeries < Legacy::Base
  set_table_name 'dreamGlobalSeries'

  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to :option, {foreign_key: "dreamGlobalSeriesOptionId", class_name: "Legacy::GlobalSeriesOption"}

  def entry_id
    dream.find_or_create_corresponding_entry.id
  end

  def noun_id
    What.for(option.title).id
  end
  def noun_type
    'What'
  end

end
