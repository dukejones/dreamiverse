VERSION = "theta b2.1"

FB_PERMS = "publish_stream, publish_checkins, user_photos" # user_location, user_checkins, email

ENV['RECAPTCHA_PUBLIC_KEY']  = '6LcfLMISAAAAAFSBbUqJIT18uqIQdlqXnb1feFN5'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LcfLMISAAAAANIq7MjfmzqNWZH_KS52xFfoXgui'

GmailSmtpSettings = {
  address: "smtp.gmail.com",
  port: 587,
  domain: "dreamcatcher.net",
  user_name: "mailer@dreamcatcher.net",
  password: "G9%Ln8(qtmZ3N3FZ5aTr",
  authentication: "plain",
  enable_starttls_auto: true
}

require 'digest/sha1'
def sha1(string)
  Digest::SHA1.hexdigest string if string.is_a? String
end

# Console Only #
def show_sql
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

if Object.const_defined?(:Wirble)
  Wirble.init
  Wirble.colorize
end

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dreamcatcher::Application.initialize!

ActiveRecord::Base.include_root_in_json = false


