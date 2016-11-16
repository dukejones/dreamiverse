require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'net/http'
require 'open-uri'
require 'digest/sha1'

Bundler.require(*Rails.groups)

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

class DreamLogFormatter < Logger::Formatter
  Format = "[%s(%d)%5s] %s\n" #.encode("ASCII")
  def call(severity, time, progname, msg)
    Format % [time.to_s(:short), $$, severity, msg2str(msg)]
  end
end

MailJetSmtpSettings = {
  address: "in.mailjet.com",
  port: 587,
  user_name: "bd8679e217fe4e656961aebb32796048",
  password: "2246a9925a8909660f1167613810fc43",
  enable_starttls_auto: true
}


module Dreamcatcher
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails application)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    config.autoload_paths += %W(#{config.root}/lib)

    config.time_zone = "Pacific Time (US & Canada)"

    # config.action_mailer.smtp_settings = GmailSmtpSettings
    config.action_mailer.smtp_settings = MailJetSmtpSettings

    initializer 'setup_asset_pipeline', :group => :all  do |app|
      # We don't want the default of everything that isn't js or css, because it pulls too many things in
      app.config.assets.precompile.shift

      # Explicitly register the extensions we are interested in compiling
      app.config.assets.precompile.push(Proc.new do |path|
        File.extname(path).in? [
          '.html', '.erb', '.haml',                 # Templates
          '.png',  '.gif', '.jpg', '.jpeg',         # Images
          '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
        ]
      end)
    end
  end
end



