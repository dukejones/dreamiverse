require 'test_helper'

class StarlightTest < ActiveSupport::TestCase

  # test "it clones if updated at yesterday" do
  #   starlight = Starlight.make(updated_at: 36.hours.ago)
  #   starlight2 = Starlight.for(starlight.entity)
  #   assert_not_equal starlight, starlight2
  # end
  # 
  # test "it doesn't clone if updated at today" do
  #   starlight = Starlight.make
  #   starlight2 = Starlight.for(starlight.entity)
  #   assert_equal starlight, starlight2
  # end

  test "starlight cascades" do
    @user = User.make(:starlight => 0)
    @entry = Entry.make(:starlight => 0, :user => @user)
    
    @entry.add_starlight!(1)
    @entry.reload; @user.reload
    assert_equal 1, @entry.starlight, "Updates its own starlight"
    assert_equal 1, @user.starlight, "Cascades starlight to the user"
  end
end
