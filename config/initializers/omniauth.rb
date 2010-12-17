Rails.application.config.middleware.use OmniAuth::Builder do  
  #provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'  
  provider :facebook, FB_API_KEY, FB_SECRET, {:scope => FB_PERMS} 
end