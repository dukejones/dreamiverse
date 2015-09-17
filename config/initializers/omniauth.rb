Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :facebook, FB_API_KEY, FB_SECRET, {:scope => FB_PERMS}
end
