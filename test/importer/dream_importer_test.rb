require 'test_helper'


class DreamImporterTest < ActiveSupport::TestCase
  setup do
    Image.stubs( :write ).
      returns(true)
    Legacy::User.stubs( :image_id).
      returns(1)
    
  end
  
  test 'dream import' do
    Legacy::Dream.offset(rand(1500)).limit(250).each do |dream|
        
      entry = Migration::DreamImporter.new(dream).migrate
      debugger unless entry.valid?
      entry.save!
      assert_equal entry.title, dream.title
      assert_equal entry.body, dream.description
      assert_equal entry.user.username, dream.user.username
      assert_equal entry.created_at, dream.created_at
      assert_equal entry.whats.map(&:name), dream.customTagsList.split(',').compact.map(&:strip).map(&:downcase).map{|t|t.slice(0...20)}.uniq
      assert_equal entry.book_list.split(','), dream.user_series.map(&:option).map(&:title)
    end
  end

end
