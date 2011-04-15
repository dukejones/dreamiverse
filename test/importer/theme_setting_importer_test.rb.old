require 'test_helper'


class ThemeSettingImporterTest < ActiveSupport::TestCase
  test "importing a theme" do
    5.times do
      theme = Legacy::ThemeSetting.all[ rand(Legacy::ThemeSetting.count) ]
      theme.dreams.each {|d| d.find_or_create_corresponding_entry }
      theme.users.each{|u| u.find_or_create_corresponding_user }
      
      migrated = Migration::ThemeSettingImporter.new(theme).migrate
      
    end
  end
end
