require 'test_helper'

class HitTest < ActiveSupport::TestCase
  test "two hits on the same page by the same ip should not be unique" do
    hit1 = Hit.make
    assert !Hit.unique?(hit1.url_path, hit1.ip_address, hit1.user), "same page, same ip hit should be non-unique."
  end

  test "two hits on different pages by the same ip should be unique" do
    hit1 = Hit.make
    assert Hit.unique?('/dreams/124', hit1.ip_address), "hit on same ip but different page should be unique"
  end
  
  test "two hits on the same page by the same ip on different days should be unique" do
    hit1 = Hit.make(updated_at: 36.hours.ago)
    assert Hit.unique?(hit1.url_path, hit1.ip_address), "same user hit on different days should be unique."
  end
  
  test "a non-unique hit should make updated_at to be the current time." do
    hit1 = Hit.make(updated_at: 12.hours.ago)
    assert !Hit.unique?(hit1.url_path, hit1.ip_address), "recent hit on same page by same ip shouldn't be unique"
    assert (hit1.reload.updated_at - Time.zone.now).abs < 5.minutes, "updated_at of non-unique hit should be current time"
  end
  
  test "a unique hit should create a new Hit" do
    h = Hit.make(updated_at: 5.days.ago)
    Hit.make
    hit1 = Hit.make
    assert_equal Hit.count, 3
    assert Hit.unique?(h.url_path, h.ip_address)
    assert_equal Hit.count, 4
  end
  
  test "recent scope should give the most recent hit first" do
    hit1 = Hit.make(updated_at: 24.hours.ago)
    hit2 = Hit.make(updated_at: 12.hours.ago)
    hit3 = Hit.make(updated_at: 15.hours.ago)
    
    assert_equal Hit.recent.first, hit2
  end
end
