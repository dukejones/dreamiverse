class Legacy::ThemeSetting < Legacy::Base
  set_table_name 'themeSetting'

  def theme_color_option
    case self.themeColorOptionId
    when '1' then "light"
    when '2' then "dark"
    else raise "invalid themeColorOptionId!"
    end
  end
end
