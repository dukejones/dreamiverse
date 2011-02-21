class Legacy::Image < Legacy::Base
  set_table_name 'image'

  belongs_to 'user', {foreign_key: "userId", class_name: "Legacy::User"}

  has_many :dream_images, {foreign_key: 'imageId', class_name: 'Legacy::DreamImage'}
  has_many :dreams, {through: :dream_images}

  # Copy Image from the fileLocation into the ImageBank.
  # Load the data and call Image#write on it.  Or add a method to Image to load a file.

  # dreamImageCrop?
end