# ExceptionNotifier::Notifier.prepend_view_path File.join(Rails.root, 'app/views')

if !Rails.env.development? && !Rails.env.test?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    :sections => %w(user request session environment backtrace),
    :email => {
      :email_prefix => "[ERROR] ",
      :sender_address => %{"dreamcatcher.net" <mailer@dreamcatcher.net>},
      :exception_recipients => %w{support@dreamcatcher.net}
    }
end
