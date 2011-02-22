class Legacy::User < Legacy::Base
  set_table_name 'user'

  belongs_to :auth_level, {foreign_key: "authLevel", class_name: "Legacy::AuthLevel"}
  belongs_to :image, {foreign_key: "avatarImageId", class_name: "Legacy::Image"}
  belongs_to :seed_code_option, {foreign_key: "seedCodeId", class_name: "Legacy::SeedCode"}
  
  # damn abandoned "class" attribute in the model conflicts with Ruby's "class" method to get your class
  # and made all the migration code FAIL
  def class
    super
  end

  belongs_to :default_privacy_option, {foreign_key: "defaultPrivacyOptionId", class_name: "Legacy::PrivacyOption"}
  belongs_to :default_theme_setting, {foreign_key: "defaultThemeSettingId", class_name: "Legacy::ThemeSetting"}

  has_many :comments, {foreign_key: 'userId', class_name: "Legacy::Comment"}


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
    # oh shit
  end
  
  def name
    fullName
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

end
