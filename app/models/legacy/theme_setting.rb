class Legacy::ThemeSetting < Legacy::Base
  set_table_name 'themeSetting'
  has_many :dreams, {foreign_key: 'themeSettingId', class_name: 'Legacy::Dream'}
  has_many :users, {foreign_key: 'defaultThemeSettingId', class_name: 'Legacy::User'}

  def theme
    case self.themeColorOptionId
    when '1' then "light"
    when '2' then "dark"
    else raise "invalid themeColorOptionId!"
    end
  end
  
  def image_id
    
  end
  
  def viewable_id
    # the dream. or user.
  end
end
