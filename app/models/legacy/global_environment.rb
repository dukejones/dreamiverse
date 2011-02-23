class Legacy::GlobalEnvironment < Legacy::Base
  set_table_name 'dreamGlobalEnvironment'

  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to :option, {foreign_key: "globalEnvironmentOptionId", class_name: "Legacy::GlobalEnvironmentOption"}
  
  def entry_id
    
  end
end
