class Legacy::DreamImage < Legacy::Base
  set_table_name 'dreamImage'

  belongs_to :dreams, {foreign_key: 'dreamId', class_name: 'Legacy::Dream'}
  belongs_to :images, {foreign_key: 'imageId', class_name: 'Legacy::Image'}
  
end