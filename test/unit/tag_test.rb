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
  
  test "custom tag same as auto tag" do
    what = What.find_or_create_by_name('duke')
    entry = Entry.make(body: 'the duke duke duke something dream')
    Tag.auto_generate_tags(entry)

    assert_equal 'auto', Tag.where(noun: what, entry: entry).first.kind

    entry.add_what_tag(what)

    assert_equal 'custom', Tag.where(noun: what, entry: entry).first.kind
  end
  
  test "sort_custom_tags" do
    # given entry with a bunch of tags
    entry = Entry.make
    whats = ['monkey', 'dolphin', 'lake', 'firestorm', 'dragon', 'palace'].map do |word|
      What.find_or_create_by_name(word)
    end
    entry.whats = whats
    # change the order of the tags in the database
    whats.shuffle!
    what_ids = whats.map(&:id)

    Tag.sort_custom_tags(entry.id, what_ids.join(','))
    
    assert_equal whats.map(&:id), entry.custom_tags.map(&:id)

  end

  test "insert new custom tag in front of auto tags" do
    # we have an entry
    entry = Entry.make
    # with custom tags and auto tags
    custom_tags = ['monkey', 'dolphin', 'lake', 'firestorm'].map do |name|
      What.find_or_create_by_name(name)
    end
    # new_tags = ['dragon', 'palace']
    auto_tags = ['monster', 'pigeon', 'didgeridoo'].map do |name|
      What.find_or_create_by_name(name)
    end
    custom_tags.each {|what| entry.add_what_tag(what) }
    auto_tags.each {|what| entry.add_what_tag(what, 'auto') }
    
    # custom tags should have the correct positions
    entry.tags.order(:position).each_with_index do |tag, index|
      assert_equal index, tag.position
    end

    num_custom_tags = entry.tags.custom.count
    dragon = What.find_or_create_by_name('dragon')
    entry.add_what_tag(dragon)
    entry.save
    assert_equal num_custom_tags, entry.tags.where(noun: dragon).first.position
    all_positions = entry.tags.map(&:position)
    assert_equal all_positions, all_positions.uniq

    # when we insert a new custom tag
    # it should be inserted in front of the auto tags
    # and all positions should be unique
  end

=begin
  test "adding a custom tags with 16 total tags drops the last auto tag off the end" do
    # create entry with 16 tags, some combination of custom and auto
    # find the last auto tag - which should drop off
    # add a custom tag
    # verify that it dropped off
    
    entry = Entry.make(body: 'giraffe bridge illuminate visualize controlled visions')  
    
    last_tag = entry.tags.last
    
    custom_tags = ['falling','limitless','sky','upwards','onwards','raging','river','valley','twilight','eve'].map do |name|
      What.find_or_create_by_name(name)
    end
    custom_tags.each { |what| entry.add_what_tag(what) }
                  
  end
=end
end
