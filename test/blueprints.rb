require 'machinist/active_record'

PW = "password"
User.blueprint do
  username { Faker::Internet.user_name.gsub('.','-') }
  name { Faker::Name.name }
  email { Faker::Internet.email }
  seed_code { "theta" }
  password { PW }
  password_confirmation { PW }
end

Entry.blueprint do
  body { Faker::Lorem.paragraphs(6).join("\n\n") }
  title { Faker::Lorem.words(5).join(' ').titleize }
  user { User.make }
  skip_auto_tags { true }
end

Hit.blueprint do
  user
  ip_address { random_ip }
  url_path { '/dreams/123' }
end

Starlight.blueprint do
  value { rand 1000 }
  entity { Dream.make }
end

Image.blueprint do
  incoming_filename { "somefile.jpg" }
  section { "Library" }
  category { "Art" }
  genre { "Africa" }
  title { Faker::Lorem.words(2).join(' ').titleize }
  artist { Faker::Name.name }
  album { Faker::Lorem.words(1).first.titleize }
  enabled { true }
  width { 128 }
  height { 256 }
  size { 1024 }
  
end

Dictionary.blueprint do
  name { Faker::Lorem.words(3).join(' ').titleize }
end

Word.blueprint do
  name { Faker::Lorem.words(1).first }
  definition { Faker::Lorem.paragraphs(2).join("\n") }
  dictionary { Dictionary.make }
end

def random_ip
  (0...4).to_a.map { rand(256) }.join('.')
end