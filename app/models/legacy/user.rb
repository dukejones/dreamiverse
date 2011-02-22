class Legacy::User < Legacy::Base
  set_table_name 'user'

  belongs_to :auth_level, {foreign_key: "authLevel", class_name: "Legacy::AuthLevel"}
  belongs_to :image, {foreign_key: "avatarImageId", class_name: "Legacy::Image"}
  
  belongs_to :default_privacy_option, {foreign_key: "defaultPrivacyOptionId", class_name: "Legacy::PrivacyOption"}
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

  belongs_to :default_theme_setting, {foreign_key: "defaultThemeSettingId", class_name: "Legacy::ThemeSetting"}

  has_many :comments, {foreign_key: 'userId', class_name: "Legacy::Comment"}

end
