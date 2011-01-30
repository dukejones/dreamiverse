require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "following" do
    u1 = User.make
    u2 = User.make
    u1.follow!(u2)
    assert u1.following?(u2)
    assert u2.followed_by?(u1)
    assert !u1.friends_with?(u2)
    assert !u2.friends_with?(u1)
    
    u2.follow!(u1)
    assert u1.friends_with?(u2)
    assert u2.friends_with?(u1)
    
    assert u1.friends.include?(u2)
  end
  
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
