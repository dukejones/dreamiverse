require 'test_helper'

class TagTest < ActiveSupport::TestCase
  test "auto_generate_tags" do
    @entry = Entry.make(title: "word", body: "word word the the banana juniper juniper")
    Tag.auto_generate_tags(@entry)

    assert @entry.whats.where(name: 'the').blank?, "Shouldn't save a blacklisted word."
    assert_equal @entry.tags.count, 3
    assert_equal @entry.tags.order(:position).map{|t| t.noun.name }, ['word', 'juniper', 'banana']
  end
end
