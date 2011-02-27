require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "followed_by scope" do
    
  end

  test "set_tags removes tags no longer in the set" do
    whats = ['dragon','hound','stove','carruthers'].map {|word| What.create(name: word) }
    new_whats = ['dragon', 'stove', 'martha'].map {|word| What.create(name: word) }
    Entry.make(:whats => whats)
    debugger
    1
  end
end
