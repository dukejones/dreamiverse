require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "accessible_by scope" do
    users = [:duke, :geoff, :phong, :leopi, :layne].each_with_object({}) {|name, hash| hash[name] = User.make(username: name.to_s) }
    users.each do |name, user|
      Entry.make(user: user, sharing_level: Entry::Sharing[:private])
      Entry.make(user: user, sharing_level: Entry::Sharing[:friends])
      Entry.make(user: user, sharing_level: Entry::Sharing[:everyone])
    end
    users[:duke].following = [users[:phong]]
    users[:geoff].following = [users[:duke], users[:phong]]
    users[:leopi].following = [users[:duke], users[:phong]]
    users[:phong].following = [users[:duke], users[:geoff]]
    users[:layne].following = [users[:geoff], users[:phong]]

    accessible = Entry.accessible_by(users[:duke])
    # where dream is public or i am friends with entry.user
    assert Entry.everyone.all?{|e| accessible.include?(e) }, "all public dreams are accessible"
    assert Entry.private.none?{|e| accessible.include?(e) }, "no private dreams are accessible"

    assert accessible.all?{|e| users[:duke].can_access?(e) }, "not all accessible_by entries are actually accessible by the user."
  end

  test "followed_by scope" do
    
  end

  test "set_whats removes tags no longer in the set" do
    whats = ['spoon','hound','stove','feh'].map {|word| What.create(name: word) }
    new_whats = ['spoon', 'stove', 'martha'].map {|word| What.create(name: word) }
    
    entry = Entry.make(:whats => whats, :title => 'visions', body: 'bridge')
    entry.set_whats(new_whats.map(&:name))  
    entry.save
    entry.reload
      
    fresh_what_names = entry.whats.map(&:name)
    
    assert_equal fresh_what_names.include?('hound'), false # make sure we delete old whats
    assert_equal fresh_what_names.include?('feh'), false # again
    assert_equal fresh_what_names.include?('visions'), true # also make sure we're not deleting the auto tags
    
  end


  test "random" do
    100.times do
      share = Entry::Sharing.values.sample
      Entry.make(sharing_level: share)
    end
    
    100.times do
      e = Entry.random
      assert e.everyone?
      assert e.type != 'article'
    end
  end

end
