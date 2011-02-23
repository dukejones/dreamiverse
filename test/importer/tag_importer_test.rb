require 'test_helper'


class TagImporterTest < ActiveSupport::TestCase
  
  # test 'emotion tags' do
  #   Migration::EmotionImporter.migrate_all
  #   
  #   Legacy::Emotion.offset(700).limit(2000).each do |emo_tag|
  #   
  #     new_emo_tag = Migration::EmotionTagImporter.new(emo_tag).migrate
  #     new_emo_tag.save!
  #     assert_equal new_emo_tag.entry.title, emo_tag.dream.title
  #     assert_equal new_emo_tag.entry.user.username, emo_tag.dream.user.username
  #     assert_equal new_emo_tag.noun.name, emo_tag.option.title
  #     assert_equal new_emo_tag.noun_type, 'Emotion'
  #   end
  # end

  test 'global environments' do
    # Legacy::GlobalEnvironment.offset(200).limit(300).each do |env|
    #   new_tag = Migration::GlobalEnvironmentImporter.new(env).migrate
    #   new_tag.save!
    #   assert_equal new_tag.noun.name, env.option.title
    #   assert new_tag.noun.kind_of? What
    #   assert_equal new_tag.entry.title, env.dream.title
    # end
    # 
    # Legacy::GlobalSeries.offset(50).limit(150).each do |series|
    #   new_tag = Migration::GlobalEnvironmentImporter.new(series).migrate
    #   new_tag.save!
    #   assert_equal new_tag.noun.name, series.option.title
    #   assert new_tag.noun.kind_of? What
    #   assert_equal new_tag.entry.title, series.dream.title
    # end

    Legacy::UserEnvironment.offset(100).limit(200).each do |env|
      new_tag = Migration::GlobalEnvironmentImporter.new(env).migrate
      new_tag.save!
      assert_equal new_tag.noun.name, env.option.title
      assert new_tag.noun.kind_of? What
      assert_equal new_tag.entry.title, env.dream.title
    end

  end
end
