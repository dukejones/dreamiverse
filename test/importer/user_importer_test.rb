require 'test_helper'


class UserImporterTest < ActiveSupport::TestCase
  
  test 'importing' do
    @legacy_user = Legacy::User.find 39
    @new_user = Migration::UserImporter.new(@legacy_user).migrate
    debugger
    1
  end
end
