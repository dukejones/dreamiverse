class Legacy::DreamImage < Legacy::Base
  set_table_name 'dreamImage'

  belongs_to :dream, {foreign_key: 'dreamId', class_name: 'Legacy::Dream'}
  belongs_to :image, {foreign_key: 'imageId', class_name: 'Legacy::Image'}
  
end