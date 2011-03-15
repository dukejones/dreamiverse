class Legacy::ThemeSetting < Legacy::Base
  set_table_name 'themeSetting'
  has_many :dreams, {foreign_key: 'themeSettingId', class_name: 'Legacy::Dream'}
  has_many :users, {foreign_key: 'defaultThemeSettingId', class_name: 'Legacy::User'}

  def self.bedsheet(name)
    where("bedsheetPath LIKE '%#{name}'")
  end
  
  def theme
    case self.themeColorOptionId
    when '1' then "light"
    when '2' then "dark"
    else raise "invalid themeColorOptionId!"
    end
  end
  
  def image_id
    image = ::Image.where("original_filename LIKE '%#{bedsheet_filename}-hi.png'").first
    
    log "Image not in system: #{bedsheet_filename}" unless image
    image._?.id
  end

  def bedsheet_filename
    bedsheetPath.split('/').last
  end
  
  def bedsheet_attachment
    scroll
  end
end
