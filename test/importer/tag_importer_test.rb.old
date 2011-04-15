require 'test_helper'


class TagImporterTest < ActiveSupport::TestCase
  setup do
    Image.stubs( :write ).
      returns(true)
    Legacy::User.stubs( :image_id).
      returns(1)
    
  end
  
  test 'emotion tags' do
    Migration::EmotionImporter.migrate_all
    
    Legacy::Emotion.offset( rand(1000) ).limit(300).each do |emo_tag|
    
      new_emo_tag = Migration::EmotionTagImporter.new(emo_tag).migrate
      new_emo_tag.save!
      assert_equal new_emo_tag.entry.title, emo_tag.dream.title
      assert_equal new_emo_tag.entry.user.username, emo_tag.dream.user.username
      assert_equal new_emo_tag.noun.name, emo_tag.option.title
      assert_equal new_emo_tag.noun_type, 'Emotion'
    end
  end
  
  test 'global environments' do
    50.times do
      env = Legacy::GlobalEnvironment.all[ rand(Legacy::GlobalEnvironment.count) ]
      new_tag = Migration::EnvironmentSeriesImporter.new(env).migrate
      debugger
      new_tag.save!
      assert_equal new_tag.noun.name, env.option.title
      assert new_tag.noun.kind_of? What
      assert_equal new_tag.entry.title, env.dream.title
    
      series = Legacy::GlobalSeries.all[ rand(Legacy::GlobalSeries.count) ]
      new_tag = Migration::EnvironmentSeriesImporter.new(series).migrate
      new_tag.save!
      assert_equal new_tag.noun.name, series.option.title
      assert new_tag.noun.kind_of? What
      assert_equal new_tag.entry.title, series.dream.title
  
      env = Legacy::UserEnvironment.all[ rand(Legacy::UserEnvironment.count) ]
      new_tag = Migration::EnvironmentSeriesImporter.new(env).migrate
      new_tag.save!
      # assert_equal new_tag.noun.name, env.option.title  # Why is it saving "Wild West" as "wild west"?
      assert new_tag.noun.kind_of? What
      assert_equal new_tag.entry.title, env.dream.title
    end
  end
  
  test "person importer" do
    50.times do
      person = Legacy::Person.all[ rand(Legacy::Person.count) ]
      # entry = Migration::DreamImporter.new(person.dream).migrate
      # entry.save!
      who = Migration::PersonImporter.new(person).migrate
      who.save!
      assert who.kind_of? Who
      assert_equal who.entries.first.id, person.dream.corresponding_object.id
    end
  end
end
