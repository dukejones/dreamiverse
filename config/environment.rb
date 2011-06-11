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

Rails.logger = Logger.new(Rails.root.join('log', "#{Rails.env}.log"), 10, 30*1024*1024)
Rails.logger.formatter = DreamLogFormatter.new

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dreamcatcher::Application.initialize!

ActiveRecord::Base.include_root_in_json = false


