require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validate_password_confirmation" do
    phong = User.create!(:name => 'Phong', :username => 'phong', :email => 'phong@dreamcatcher.net')
    phong.password = "password"

    phong.password_confirmation = "anotherpassword"
    assert (!phong.save)
    
    phong.password_confirmation = "password"
    assert (phong.save)
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
    
    
    # user = create!(
    #   :name => auth['user_info']['name'],
    #   :username => (auth['user_info']['nickname'] || auth['user_info']['name'].gsub(' ', '').downcase)
    # )
    
  end
end
