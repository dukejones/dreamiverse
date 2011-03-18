class Legacy::Image < Legacy::Base
  Dir = "#{Rails.root}/tmp/images/user"
  
  set_table_name 'image'

  def corresponding_object
    find_corresponding_image
  end
  
  def find_corresponding_image
    if !File.exists?(self.fullpath)
      log("File does not exist! #{self.fullpath}")
      return nil
    end
    ::Image.where(original_filename: filename, size: File.size(self.fullpath)).first
  end

  def find_or_create_corresponding_image
    image = find_corresponding_image
    if image.blank?
      image = Migration::ImageImporter.new(self).migrate
      if image.valid?
        image.save!
      else
        image = nil
      end
    end
    image
  end
  
  belongs_to :user, {foreign_key: "userId", class_name: "Legacy::User"}

  has_many :dream_images, {foreign_key: 'imageId', class_name: 'Legacy::DreamImage'}
  has_many :dreams, {through: :dream_images}
  def self.valid
    images = self.all
    images.reject!{|i| !i.avatar? && i.dreams.blank? }
    images.reject!{|i| i.avatar? && i.user.blank? }
    images.select!{|i| i.filename =~ /^.*\.(png|jpg|gif|jpeg|JPG|PNG)$/ }
    images.reject!{|i| !File.exists? "#{Dir}/#{i.path}" || File.size("#{Dir}/#{i.path}") == 0 }
    images
  end
  
  def valid?
    !(!self.avatar? && self.dreams.blank?) &&
    !(self.avatar? && self.user.blank?) &&
    (self.filename =~ /^.*\.(png|jpg|gif|jpeg|JPG|PNG)$/) &&
    (File.exists? self.fullpath)
  end

  def title
    filename
  end

  def avatar?
    if name.blank?
      return true
    elsif name == '_64'
      return false
    else
      raise 'unknown name value for image!'
    end
  end
  
  def section
    if avatar?
      "Avatar"
    else
      "Library"
    end
  end

  def filename
    if avatar?
      fileLocation
    else
      fileLocation.split('/').last
    end
  end
  def original_filename
    filename
  end
  def path
    if avatar?
      "avatar/#{self.user.id}/#{self.filename}"
    else
      "dream-galleries/#{self.dreams.first.id}/original/#{self.filename}"
    end
  end

  def uploaded_by_id
    # user.find_or_create_corresponding_user.id
    nil
  end
  
  def fullpath
    "#{Dir}/#{path}"
  end
end
