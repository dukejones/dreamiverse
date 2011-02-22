require 'test_helper'


class TagImporterTest < ActiveSupport::TestCase
  
  test 'emotion tags' do
    Migration::EmotionImporter.migrate_all
    
    Legacy::Emotion.offset(700).each do |emo_tag|
    
      new_emo_tag = Migration::EmotionTagImporter.new(emo_tag).migrate
      new_emo_tag.save!
      assert_equal new_emo_tag.entry.title, emo_tag.dream.title
      assert_equal new_emo_tag.entry.user.username, emo_tag.dream.user.username
      assert_equal new_emo_tag.noun.name, emo_tag.option.title
      assert_equal new_emo_tag.noun_type, 'Emotion'
    end
  end

  test 'dream tags' do
    
  end
end
