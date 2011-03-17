class Legacy::User < Legacy::Base
  set_table_name 'user'

  def corresponding_object
    find_corresponding_user
  end
  
  def find_corresponding_user
    ::User.find_by_username_and_email(self.username, self.email) || log("user not created for #{self.username}")
  end
  
  def find_or_create_corresponding_user
    new_user = find_corresponding_user
    if new_user.nil?
      new_user = Migration::UserImporter.new(self).migrate
      new_user.save!
    end
    new_user
  end

  belongs_to :auth_level_option, {foreign_key: "authLevel", class_name: "Legacy::AuthLevel"}
  belongs_to :image, {foreign_key: "avatarImageId", class_name: "Legacy::Image"}
  belongs_to :seed_code_option, {foreign_key: "seedCodeId", class_name: "Legacy::SeedCode"}
  belongs_to :avatar_image, {foreign_key: 'avatarImageId', class_name: 'Legacy::Image'}
  has_many :location_options, {foreign_key: 'userId', class_name: 'Legacy::UserLocationOption'}
  has_many :dreams, {foreign_key: 'userId', class_name: 'Legacy::Dream'}

  # abandoned "class" attribute in the legacy model conflicts with Ruby's "class" method
  def class
    super
  end

  belongs_to :default_privacy_option, {foreign_key: "defaultPrivacyOptionId", class_name: "Legacy::PrivacyOption"}
  belongs_to :default_theme_setting, {foreign_key: "defaultThemeSettingId", class_name: "Legacy::ThemeSetting"}

  has_many :comments, {foreign_key: 'userId', class_name: "Legacy::Comment"}

  def auth_level
    authLevel
  end

  def default_sharing_level
    case default_privacy_option._?.title
    when 'public', nil
      Entry::Sharing[:everyone]
    when 'anonymous'
      Entry::Sharing[:anonymous]
    when 'private'
      Entry::Sharing[:private]
    end
  end

  def encrypted_password
    pass
  end
  
  def image_id
    return nil if avatar_image.nil?
    # new_image = avatar_image.find_or_create_corresponding_image
    new_image = avatar_image.find_corresponding_image
    log "Cannot find avatar image: #{avatar_image.fileLocation} for user: #{self.id} #{self.username}" unless new_image
    new_image._?.id
  end
  
  def name
    fullName
  end
  
  def starlight
    sum = 0
    self.dreams.each do |dream|
      sum += dream.views.count
    end
    
    sum
  end

  def cumulative_starlight
    sum = 0
    self.dreams.each do |dream|
      sum += dream.views.count
    end
    sum
  end
  
  def seed_code
    seed_code_option.title
  end
  
  def username
    userName
  end

  def skype
    self[:skype] == 'n/a' ? nil : self[:skype]
  end
  def phone
    self[:phone] == 'n/a' ? nil : self[:phone]
  end
  
  def created_at
    signUpDate
  end

  def updated_at
    lastLoggedIn
  end

end
