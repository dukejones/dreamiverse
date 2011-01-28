require 'test_helper'

class StarlightTest < ActiveSupport::TestCase

  test "it clones if updated at yesterday" do
    starlight = Starlight.make(updated_at: 36.hours.ago)
    starlight2 = Starlight.for(starlight.entity)
    assert_not_equal starlight, starlight2
  end
  
  test "it doesn't clone if updated at today" do
    starlight = Starlight.make
    starlight2 = Starlight.for(starlight.entity)
    assert_equal starlight, starlight2
  end
  
end
