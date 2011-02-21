class Legacy::User < Legacy::Base
  set_table_name 'user'

  belongs_to :auth_level, {foreign_key: "authLevel", class_name: "Legacy::AuthLevel"}
  belongs_to :image, {foreign_key: "avatarImageId", class_name: "Legacy::Image"}
  
  belongs_to :default_privacy_option, {foreign_key: "defaultPrivacyOptionId", class_name: "Legacy::PrivacyOption"}
  belongs_to :default_theme_setting, {foreign_key: "defaultThemeSettingId", class_name: "Legacy::ThemeSetting"}
end
