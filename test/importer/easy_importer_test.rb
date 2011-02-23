require 'test_helper'


class EasyImporterTest < ActiveSupport::TestCase
  # test "country importer" do
  #   Legacy::Country.all.each do |legacy_country|
  #     new_country = Migration::CountryImporter.new(legacy_country).migrate
  #     assert new_country.save!
  #     assert_equal new_country.name, legacy_country.title
  #     assert_equal new_country.iso2, legacy_country.iso2
  #     assert_equal new_country.iso3, legacy_country.iso3
  #   end
  # end
  
  # test "location importer" do
  #   Legacy::UserLocationOption.limit(100).each do |loc|
  #     new_loc = Migration::LocationImporter.new(loc).migrate
  #     assert new_loc.save!
  #     assert_equal new_loc.province, loc.location.region
  #     assert_equal new_loc.name, loc.title
  #     assert_equal new_loc.country, loc.location.countryIso2
  #   end
  # end

  # test "emotion importer" do
  #   Legacy::EmotionOption.all.each do |emotion|
  #     new_emo = Migration::EmotionImporter.new(emotion).migrate
  #     assert new_emo.save!
  #     assert_equal new_emo.name, emotion.title
  #   end
  # end

  test "comment importer" do
    Legacy::Comment.all[-30..-5].each do |comment|
      new_comment = Migration::CommentImporter.new(comment).migrate
      new_comment.save!
      debugger
      assert_equal new_comment.body, comment.comment
    end
  end
end