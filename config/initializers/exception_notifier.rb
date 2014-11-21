# ExceptionNotifier::Notifier.prepend_view_path File.join(Rails.root, 'app/views')

if !Rails.env.development? && !Rails.env.test?
  require 'exception_notifier'
  Rails.Application.config.middleware.use ExceptionNotifier,
    :sections => %w(user request session environment backtrace),
    :email_prefix => "[ERROR] ",
    :sender_address => %{"dreamcatcher.net" <mailer@dreamcatcher.net>},
    :exception_recipients => %w{support@dreamcatcher.net}
end