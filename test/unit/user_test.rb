require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "follow" do
    geo = User.make
    eph = User.make
    phong = User.make
    eph.following << geo

    assert eph.following == [geo]
    assert eph.following?(geo)

    assert geo.followers == [eph]
    assert geo.followed_by?(eph)

    assert eph.followers.empty?
    assert geo.following.empty?
    assert !eph.friends_with?(geo)
    assert !geo.friends_with?(eph)
    
    phong.following << geo
    geo.reload
    assert geo.followers == [eph, phong]
    assert geo.followed_by?(phong)
    assert phong.following?(geo)
    assert !phong.following?(eph)
    assert geo.followed_by?(eph)
  end
  
  test 'friend' do
    geo = User.make
    eph = User.make
    phong = User.make
    geo.following << eph
    geo.following << phong
    geo.followers << eph
    [geo, eph, phong].map(&:reload)
    
    assert eph.friends_with?(geo)
    assert geo.friends_with?(eph)
    assert !geo.friends_with?(phong)

    assert geo.friends.include?(eph)
    assert !geo.friends.include?(phong)
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
