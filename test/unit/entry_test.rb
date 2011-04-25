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
    
    entry = Entry.make(whats: whats, title: 'visions', body: 'bridge')
    Tag.auto_generate_tags(entry)
    entry.set_whats(new_whats.map(&:name))  
    entry.save
    entry.reload
      
    fresh_what_names = entry.whats.map(&:name)
    
    assert_equal fresh_what_names.include?('hound'), false # make sure we delete old whats
    assert_equal fresh_what_names.include?('feh'), false # again
    assert_equal fresh_what_names.include?('visions'), true # also make sure we're not deleting the auto tags
    
  end

  test "set_links sets links" do
    e = Entry.make
    
    # Adds a single link
    links_attrs = [{url: "http://www.basementshaman.com/", title: "The Basement Shaman"}]
    e.set_links(links_attrs)
    assert_equal e.links.first.url, links_attrs.first[:url]
    
    # Gets rid of links not passed in.
    links_attrs2 = [{url: "http://www.youtube.com/watch?v=8z32JTnRrHc&feature=related", title: "Nacy Holt, Boomerang"}]
    e.set_links(links_attrs2)
    assert !e.links.map(&:url).include?(links_attrs.first[:url])
    assert e.links.map(&:url).include?(links_attrs2.first[:url])
    
    # Doesn't re-create the same link.
    links_attrs3 = links_attrs + links_attrs2
    previous_link_id = e.links.first.id
    e.set_links(links_attrs3)
    assert e.links.map(&:id).include?(previous_link_id), "The same link should not be created again."
    
    # Sets a new title of an existing link without recreating the link.
    shaman_link = e.links.where(url: links_attrs.first[:url]).first
    previous_link_id = shaman_link.id
    links_attrs.first[:title] = "Basement Medicino"
    e.set_links(links_attrs)
    new_shaman_link = e.links.where(url: links_attrs.first[:url]).first
    assert_equal previous_link_id, new_shaman_link.id, "The same link should not be created again."
    assert_equal links_attrs.first[:url], new_shaman_link.url
    assert_equal links_attrs.first[:title], new_shaman_link.title
  end

  test "set_emotions sets the emotions" do
    e = Entry.make
    
    # It sets the emotions' and their intensities.
    emotion_params = {"love"=>"1", "joy"=>"2", "surprise"=>"3", "anger"=>"4"}
    e.set_emotions(emotion_params)
    assert_equal 4, e.emotions.count
    assert_equal 1, e.tags.emotion.named('love').first.intensity
    assert_equal 2, e.tags.emotion.named('joy').first.intensity
    assert_equal 3, e.tags.emotion.named('surprise').first.intensity
    assert_equal 4, e.tags.emotion.named('anger').first.intensity
    
    # It changes the emotion and doesn't make a new tag
    emotion_params = {"love"=>"4"}
    old_love_tag = e.tags.emotion.named('love').first
    e.set_emotions(emotion_params)
    assert_equal 4, e.emotions.count
    assert_equal 4, e.tags.emotion.named('love').first.intensity
    assert_equal 3, e.tags.emotion.named('surprise').first.intensity # sanity check
    assert_equal old_love_tag.id, e.tags.emotion.named('love').first.id
  end
  
  test "set_emotions doesn't set emotions with 0 intensity" do
    e = Entry.make
    
    emotion_params = {"love" => "3", "anger" => "0"}
    e.set_emotions(emotion_params)
    assert_equal 3, e.tags.emotion.named('love').first.intensity
    assert_equal nil, e.tags.emotion.named('anger').first
  end
  
  test "set_emotions works on new entry" do
    # e = Entry.new(body: 'stuff', user: User.make)
    # emotion_params = {"love"=>"1", "joy"=>"2", "surprise"=>"3", "anger"=>"4"}
    # e.set_emotions
  end

  test "random entry method selects only everyone entries." do
    20.times do
      share = Entry::Sharing.values.sample
      Entry.make(sharing_level: share)
    end
    Entry.make(sharing_level: Entry::Sharing[:everyone]) # so there's at least one
    
    30.times do
      e = Entry.random
      assert !e.nil?
      assert e.everyone?
      assert e.type != 'article'
    end
  end

  test "add_what_tag adds a tag" do
    entry = Entry.make
    what = What.for('unicorn')
    what2 = What.for('klingon')
    assert_equal 0, entry.tags.count
    entry.add_what_tag(what)
    assert_equal 1, entry.whats.count
    assert_equal what, entry.whats.first
    # can add another tag
    entry.add_what_tag(what2)
    assert_equal 2, entry.whats.count
    assert_equal what2, entry.whats.last
    # if there's an auto tag, and you add it as a custom tag, it'll make the tag custom and not create a new tag.
    unicorn_tag = entry.tags.what.named('unicorn').first
    unicorn_tag.update_attribute(:kind, 'auto')
    entry.add_what_tag(what)
    new_unicorn_tag = entry.tags.what.named('unicorn').first
    assert_equal unicorn_tag, new_unicorn_tag
    assert_equal 'custom', new_unicorn_tag.kind
  end

  # test "what happens when adding a tag with an invalid tag name" do
  #   entry = Entry.make
  #   entry.set_whats(['unicorn', 'Ka-'])
  # end

  test "reorder tags doesn't create positions for emotion tags" do
    entry = Entry.make
    Tag.auto_generate_tags(entry, 16)
    
    entry
    user_tags = ['dragon', 'flower', 'volcano', 'hummingbird']
    entry.set_whats(user_tags)
    entry.set_emotions({'fear' => '3', 'love' => '5', 'joy' => '5'})
    entry.body += ' '
    entry.save

    num_tags = 16 + user_tags.size
    assert_equal num_tags, entry.what_tags.count
    assert_equal (0...num_tags).to_a, entry.what_tags.map(&:position).sort
  end
  
end
