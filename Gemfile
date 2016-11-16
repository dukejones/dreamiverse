ruby "2.2.3"
source 'http://rubygems.org'

gem 'rails', '~> 4.2'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'unicorn'
gem 'puma'
gem 'foreman'
gem 'mysql2'
gem 'haml'

# New asset pipeline

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'

# Asset stuff -- to be decided
# gem 'jammit'
# gem 'coffee-script'
# gem 'barista'

gem 'omniauth'
gem 'omniauth-facebook'
gem 'exception_notification'
gem 'nokogiri'
gem 'dalli'
gem 'resque', :require => 'resque/server'

gem 'mini_magick'
# gem 'rmagick'
# gem 'micro_magick'

gem 'prawn'
gem 'wicked_pdf'
gem 'pdfkit'
gem 'rubyzip', require: 'zip'

gem 'recaptcha', :require => 'recaptcha/rails'
# gem 'resque-scheduler'
gem 'whenever', :require => false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Bundle the extra gems:
# gem 'bj'
# gem 'aws-s3', :require => 'aws/s3'
# gem 'rgeo' - when we get into doing lots of geocoding / calculations.

group :development do
  gem 'capistrano-rails', require: false
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma', require: false
  gem 'better_errors'
  gem 'quiet_assets'
  # gem 'letter_opener'
end

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'awesome_print'
  gem 'guard-rspec', require: false
end

# group :production do
#   gem 'syslogger'
#   # gem 'buffered_syslogger'
# end

# http://robots.thoughtbot.com/post/1658763359/thoughtbot-and-the-holy-grail
# group :test, :cucumber do
#   gem 'akephalos', :git => 'git://github.com/thoughtbot/akephalos.git'
#   gem "cucumber-rails"
#   gem "capybara"
#   gem "database_cleaner"
#   gem "treetop"
#   gem "launchy"
# end
