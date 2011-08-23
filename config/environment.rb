VERSION = "theta b2.5"

FB_PERMS = "publish_stream, publish_checkins, user_photos" # user_location, user_checkins, email

ENV['RECAPTCHA_PUBLIC_KEY']  = '6LcfLMISAAAAAFSBbUqJIT18uqIQdlqXnb1feFN5'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LcfLMISAAAAANIq7MjfmzqNWZH_KS52xFfoXgui'

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dreamcatcher::Application.initialize!

ActiveRecord::Base.include_root_in_json = false


