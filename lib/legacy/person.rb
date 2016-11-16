class Legacy::Person < Legacy::Base
  set_table_name 'dreamPerson'

  belongs_to :dream, {foreign_key: "dreamId", class_name: "Legacy::Dream"}

  def name
    title.strip.gsub(/[ ]+/, ' ')
  end
  
  
end
