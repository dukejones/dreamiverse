require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "validate_password_confirmation" do
    assert_raise(ActiveRecord::RecordInvalid) { User.make(password: 'pw1', password_confirmation: 'pw2') }
  end

  test "create_with_omniauth" do
    omniauth = {
      'provider' => 'facebook',
      'uid' => '123456',
      'user_info' => {
        'name' => 'Phong',
        'nickname' => 'phonger'
      }
    }
  end
end
