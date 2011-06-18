FB_APP_ID = '124682597593261'
FB_API_KEY = 'dee8b94c97c7a98066ccfacd5c5556eb'
FB_SECRET = '346d46fd33affd1119dfed9ca29261ab'

Dreamcatcher::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  # config.action_controller.perform_caching = false
  config.action_controller.perform_caching = true
  config.cache_store = :mem_cache_store

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  # Mailtrap
  # config.action_mailer.smtp_settings = { port: 2525 }
  # Gmail
  # config.action_mailer.smtp_settings = GmailSmtpSettings

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  config.action_mailer.default_url_options = { :host => 'localhost', :port => 3000 }

end

