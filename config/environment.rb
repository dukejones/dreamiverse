
require 'digest/sha1'
def sha1(*args)
  Digest::SHA1.hexdigest *args
end


# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dreamcatcher::Application.initialize!


