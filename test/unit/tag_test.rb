require 'test_helper'

class TagTest < ActiveSupport::TestCase
  # test "auto_generate_tags" do
  #   @entry = Entry.make(title: "word", body: "word word the the banana juniper juniper")
  #   Tag.auto_generate_tags(@entry)
  # 
  #   assert @entry.whats.where(name: 'the').blank?, "Shouldn't save a blacklisted word."
  #   assert_equal @entry.tags.count, 3
  #   assert_equal @entry.tags.order(:position).map{|t| t.noun.name }, ['word', 'juniper', 'banana']
  # end
  
  test "Inserting a new custom tag with the same name as an auto tag" do
    what = What.for('duke')
    entry = Entry.make(body: 'the duke duke duke something dream')
    Tag.auto_generate_tags(entry)

    assert_equal 'auto', Tag.where(noun: what, entry: entry).first.kind

    entry.add_what_tag(what)

    assert_equal 'custom', Tag.where(noun: what, entry: entry).first.kind
  end
  
  test "order_custom_tags" do
    # given entry with a bunch of tags
    entry = Entry.make
    whats = ['monkey', 'dolphin', 'lake', 'firestorm', 'dragon', 'palace'].map do |word|
      What.for(word)
    end
    entry.whats = whats
    # change the order of the tags in the database
    whats.shuffle!
    what_ids = whats.map(&:id)

    Tag.order_custom_tags(entry.id, what_ids.join(','))
    
    assert_equal whats.map(&:id), entry.tags.custom.whats.map(&:id)

  end

  test "insert new custom tag in front of auto tags" do
    # we have an entry
    entry = Entry.make
    # with custom tags and auto tags
    custom_tags = ['monkey', 'dolphin', 'lake', 'firestorm'].map do |name|
      What.for(name)
    end
    # new_tags = ['dragon', 'palace']
    auto_tags = ['monster', 'pigeon', 'didgeridoo'].map do |name|
      What.for(name)
    end
    custom_tags.each {|what| entry.add_what_tag(what) }
    auto_tags.each {|what| entry.add_what_tag(what, 'auto') }
    
    # custom tags should have the correct positions
    entry.tags.order(:position).each_with_index do |tag, index|
      assert_equal index, tag.position
    end

    # Add a new custom tag. Verify that its position is at the end of the custom tags, before the auto tags.
    num_custom_tags = entry.tags.custom.count
    dragon = What.for('dragon')
    entry.add_what_tag(dragon)
    entry.save
    entry.reorder_tags
    assert_equal num_custom_tags, entry.tags.where(noun: dragon).first.position
    all_positions = entry.tags.map(&:position)
    assert_equal all_positions, all_positions.uniq

    # when we insert a new custom tag
    # it should be inserted in front of the auto tags
    # and all positions should be unique
  end


  test "adding a custom tag with 16 total tags drops the last auto tag off the end" do
    # create entry with 16 tags, some combination of custom and auto
    # find the last auto tag - which should drop off
    # add a custom tag
    # verify that it dropped off
    
    entry = Entry.make(title: 'visions', body: 'giraffe bridge illuminate visualize controlled', skip_auto_tags: false)
    
    last_auto_tag = entry.tags.auto.last
    
    custom_tags = ['falling','limitless','sky','upwards','onwards','raging','river','valley','twilight','eve']
    custom_tags.map! { |name| What.for(name) }
    
    custom_tags.each { |what| entry.add_what_tag(what) }

    extra_tag = What.for('Jeremiah')
    entry.add_what_tag(extra_tag)
    
    entry.reorder_tags  
    entry.reload

    last_auto_tag_exists = Tag.find_by_id(last_auto_tag.id)
    
    assert_equal last_auto_tag_exists, nil
  end


  test "verify that tag entries won't allow nil values for entry_id and noun_id colums" do
    
    tag1 = Tag.create(entry_id: nil)
    tag2 = Tag.create(entry_id: 999, noun_id: nil)
    
    assert_equal tag1.id, nil
    assert_equal tag2.id, nil
      
  end


  test "verify that we have 16 total tags for an entry after the auto tag generator runs, assuming 16 auto tags exist" do

    entry = Entry.make(body: 'test1 test2 test3 test4 test5 test6 test7 test8 tes9 tes10 tes11 tes12 tes13 tes14 tes15 tes16')

    orig_tags = entry.tags.count

    Tag.auto_generate_tags(entry)
    entry.reorder_tags      
    entry.reload 

    num_tags = entry.tags.count

    assert_equal num_tags, 16

  end

  test "autotagging doesn't autotag html tags or url's in the body of the entry" do
    entry = Entry.make(body: "From the macrocosm of human civilization, to the microcosm of a single human being, we are beginning to harness the power of Sol.\r\n\r\nHere Comes the Sun\r\nUplifting 48 min documentary on the migration to solar power:\r\nhttp://www.youtube.com/watch?v=mLHBFyfvK8A&feature=player_embedded\r\n<iframe title=\"YouTube video player\" width=\"480\" height=\"390\" src=\"http://www.youtube.com/embed/mLHBFyfvK8A\" frameborder=\"0\" allowfullscreen></iframe>\r\n\r\nThe Sun\r\nVisually appealing BBC documentary on solar weather, spots and flares\r\n30 min\r\nhttp://www.youtube.com/watch?v=cPWFv4f00xw&feature=player_embedded\r\n<iframe title=\"YouTube video player\" width=\"480\" height=\"390\" src=\"http://www.youtube.com/embed/cPWFv4f00xw\" frameborder=\"0\" allowfullscreen></iframe>\r\n\r\nEat the Sun! - Sungazing film trailer\r\nhttp://www.youtube.com/watch?v=ZM9iDdkKZ7M&feature=player_embedded\r\n<iframe title=\"YouTube video player\" width=\"640\" height=\"390\" src=\"http://www.youtube.com/embed/ZM9iDdkKZ7M\" frameborder=\"0\" allowfullscreen></iframe>\r\n\r\nPranasynthesis - 4 min, amazing\r\nhttp://www.youtube.com/watch?v=ewoDVPCLnt0\r\n<iframe title=\"YouTube video player\" width=\"480\" height=\"390\" src=\"http://www.youtube.com/embed/ewoDVPCLnt0\" frameborder=\"0\" allowfullscreen></iframe>\r\n\r\nScroll down for video of Hira Ratan Manek (HRM), who has been examined by universities and NASA for the potential of sungazing-assisted space travel.")
    
    Tag.auto_generate_tags(entry)
    
    tag_words = entry.tags.auto.whats.map(&:name)
    assert tag_words.none?{|tag_word| tag_word['<iframe'] }
    assert tag_words.none?{|tag_word| tag_word['http://'] }
    assert tag_words.none?{|tag_word| tag_word['youtube'] }
  end
  
  test "autotagging an entry with emotions still creates 16 tags" do
    entry = Entry.make
    entry.set_whats(['dragonfly', 'lioness', 'curious', 'venus', 'flytrap'])
    entry.set_emotions({'fear' => 3, 'surprise' => 4, 'joy' => 5})

    Tag.auto_generate_tags(entry, 16) 
    
    # Sanity check: 16 total tags
    assert_equal 16, entry.what_tags.count
    # If there are 5 custom whats, there should be 11 auto whats

    assert_equal (16 - entry.what_tags.custom.count), entry.tags.auto.count
  end
end
