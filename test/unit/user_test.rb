#require 'test_helper'


require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "user doesn't save if password confirmation doesn't equal password" do
    phong = User.create!(:name => 'Phong', :nickname => 'phong', :email => 'phong@dreamcatcher.net')
    
    assert (phong.save == true)
  end
end
