class Legacy::ThemeSetting < Legacy::Base
  set_table_name 'themeSetting'

  def theme_color_option
    case self.themeColorOptionId
    when '1': "light"
    when '2': "dark"
    else: raise "invalid themeColorOptionId!"
    end
  end
end
