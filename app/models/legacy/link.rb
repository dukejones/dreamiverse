class Legacy::Link < Legacy::Base
  set_table_name 'dreamLink'
  belongs_to 'dream', :class_name => "Legacy::Dream"
end