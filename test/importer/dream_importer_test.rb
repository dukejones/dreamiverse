require 'test_helper'


class DreamImporterTest < ActiveSupport::TestCase
  
  test 'dream import' do
    Legacy::Dream.limit(250).each do |dream|
        
      entry = Migration::DreamImporter.new(dream).migrate
    
      assert entry.save!
      assert_equal entry.title, dream.title
      assert_equal entry.body, dream.description
      assert_equal entry.user.username, dream.user.username
      assert_equal entry.created_at, dream.created_at
    end
  end

end
