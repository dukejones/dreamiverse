require 'test_helper'


class UserImporterTest < ActiveSupport::TestCase
  
  # test 'importing' do
  #   Legacy::User.all.each do |legacy_user|
  #     puts legacy_user.inspect
  #     new_user = Migration::UserImporter.new(legacy_user).migrate
  # 
  #     assert new_user.save!
  #     assert_equal new_user.username, legacy_user.userName
  #     assert_equal new_user.email, legacy_user.email
  #     assert_equal new_user.encrypted_password, legacy_user.pass
  #     assert_equal nil, new_user.skype if legacy_user.skype == 'n/a'
  #     assert_equal new_user.view_preference._?.theme, legacy_user.default_theme_setting._?.theme
  #     assert_equal new_user.auth_level, legacy_user.auth_level
  #   end
  # end
  
  test 'user location' do
    Legacy::UserLocationOption.joins(:location).limit(500).each do |location|
      where = Migration::UserLocationImporter.new(location).migrate
      # create a where - associate it with the user
      where.save!
      assert_equal where.name, location.title
      assert_equal where.city, location.location.city
      assert_equal where.province, location.location.region
      user = location.user.find_corresponding_user
      assert user.wheres.exists? where
    end
  end

end
