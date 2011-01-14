
require 'digest/sha1'
def sha1(string)
  Digest::SHA1.hexdigest string if string.is_a? String
end


# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dreamcatcher::Application.initialize!

ActiveRecord::Base.include_root_in_json = false

