class Legacy::Dream < Legacy::Base
  set_table_name 'dream'
  
  has_many :comments, {foreign_key: 'dreamId', class_name: "Legacy::Comment"}

  has_many :dream_images, {foreign_key: 'dreamId', class_name: 'Legacy::DreamImage'}
  has_many :images, {through: :dream_images}
end