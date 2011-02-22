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

if Image.where(:title => "Default Avatar").count == 0
  puts "Seeding Default Avatar..."
  avatar_filename = "avatar_lg.jpg"
  default_avatar_image = Image.create({
    :section => "Avatar",
    :title => "Default Avatar",
    :artist => "Andrew Jones",
    :incoming_filename => avatar_filename
  })
  avatar_file = open("#{Rails.root}/db/#{avatar_filename}", "rb")
  default_avatar_image.write( avatar_file.read )
end
