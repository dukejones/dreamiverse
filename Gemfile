source 'http://rubygems.org'

gem 'rails', '3.0.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mini_magick'
gem 'mysql2'
gem 'haml'
gem 'omniauth'
gem 'coffee-script'
gem 'barista'
gem 'coffee-haml-filter'
gem 'meta_where'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'exception_notification'

# Bundle the extra gems:
# gem 'bj'
gem 'nokogiri'
# gem 'aws-s3', :require => 'aws/s3'
gem 'whenever', :require => false
# gem 'rgeo' - when we get into doing lots of geocoding / calculations.

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
end

group :test do
  gem 'webrat'
  # gem 'factory_girl'
  gem 'machinist'
  gem 'faker'
  gem 'mocha'
end

### Install these gems yourself if you wish to use Autotest. ###
# autotest-standalone
# autotest-rails-pure
### Mac
# autotest-fsevent
# autotest-growl
### Linux
# autotest-inotify


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
