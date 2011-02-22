require 'test_helper'


class UserImporterTest < ActiveSupport::TestCase
  
  test 'importing' do
    @legacy_user = Legacy::User.find 39
    @new_user = Migration::UserImporter.new(@legacy_user).migrate

    assert @new_user.save!
    assert_equal @new_user.username, @legacy_user.userName
    assert_equal @new_user.email, @legacy_user.email
    assert_equal @new_user.encrypted_password, @legacy_user.pass
    assert_equal nil, @new_user.skype if @legacy_user.skype == 'n/a'
  end

end
