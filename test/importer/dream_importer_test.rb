require 'test_helper'


class DreamImporterTest < ActiveSupport::TestCase
  
  test 'dream import' do
    Legacy::Dream.limit(250).each do |dream|
        
      entry = Migration::DreamImporter.new(dream).migrate
    
      entry.save!
      assert_equal entry.title, dream.title
      assert_equal entry.body, dream.description
      assert_equal entry.user.username, dream.user.username
      assert_equal entry.created_at, dream.created_at
      assert_equal entry.whats.map(&:name), dream.customTagsList.split(',').compact.map(&:strip).map(&:downcase).uniq
    end
  end

end
