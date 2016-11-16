class Legacy::GlobalEnvironment < Legacy::Base
  set_table_name 'dreamGlobalEnvironment'

  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to :option, {foreign_key: "dreamGlobalEnvironmentOptionId", class_name: "Legacy::GlobalEnvironmentOption"}
  
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
