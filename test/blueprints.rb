require 'machinist/active_record'

PW = "password"
User.blueprint do
  username { Faker::Internet.user_name }
  name { Faker::Name.name }
  email { Faker::Internet.email }
  seed_code { "theta" }
  password { PW }
  password_confirmation { PW }
end

Dream.blueprint do
  body { Faker::Lorem.paragraphs(6) }
  title { Faker::Lorem.words(5).titleize }
  
end

Hit.blueprint do
  user
  ip_address { random_ip }
  url_path { '/dreams/123' }
end



def random_ip
  (0...4).to_a.map { rand(256) }.join('.')
end