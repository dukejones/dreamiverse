unless Rails.env == 'development'
  require 'exception_notifier'
  Dreamcatcher::Application.config.middleware.use ExceptionNotifier,
    :sections => %w(user request session environment backtrace),
    :email_prefix => "[ERROR] ",
    :sender_address => %{"dreamcatcher.net" <mailer@dreamcatcher.net>},
    :exception_recipients => %w{support@dreamcatcher.net}
end