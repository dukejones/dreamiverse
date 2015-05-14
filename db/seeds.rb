# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

puts 'Seeding BlacklistWords...'
require "#{Rails.root}/lib/init_nephele_blacklist_words"
InitNepheleBlacklistWords.init_first_words 

AVATAR_FILENAME = "avatar_lg.jpg"
if Image.where(:title => "Default Avatar").count == 0
  puts "Seeding Default Avatar..."
  default_avatar_image = Image.create({
    :section => "Avatar",
    :title => "Default Avatar",
    :artist => "Andrew Jones",
    :incoming_filename => AVATAR_FILENAME
  })
  default_avatar_image.intake_file "#{Rails.root}/db/#{AVATAR_FILENAME}"
end

puts "Seeding Emotions..."
%w(love joy surprise anger mystical wonder sadness stress fear).each do |emotion_name|
  Emotion.create(name: emotion_name) unless Emotion.where(name: emotion_name).count > 0
end
