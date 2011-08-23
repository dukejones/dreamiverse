source 'http://rubygems.org'

gem 'rails', '3.0.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mini_magick'
gem 'mysql2', '~>0.2.7'
gem 'haml'
gem 'sass'
gem 'omniauth'
# gem 'coffee-script'
gem 'barista'
# gem 'coffee-haml-filter'
gem 'meta_where'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'exception_notification'
gem 'nokogiri'
gem 'whenever', :require => false
gem 'jammit'
gem 'memcache-client'

# Bundle the extra gems:
# gem 'bj'
# gem 'aws-s3', :require => 'aws/s3'
# gem 'rgeo' - when we get into doing lots of geocoding / calculations.

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'wirble'
  gem 'active_reload'
end

group :test do
  gem 'webrat'
  gem 'machinist'
  gem 'faker'
  gem 'mocha'
  gem 'infinity_test', :git => "git://github.com/tomas-stefano/infinity_test.git"
end

group :development, :test do
  gem 'ruby-debug19', :require => 'ruby-debug'
end

# http://robots.thoughtbot.com/post/1658763359/thoughtbot-and-the-holy-grail
# group :test, :cucumber do
#   gem 'akephalos', :git => 'git://github.com/thoughtbot/akephalos.git'
#   gem "cucumber-rails"
#   gem "capybara"
#   gem "database_cleaner"
#   gem "treetop"
#   gem "launchy"
# end
