# Append the environment to the subject
# And make sure we're never sending mail to any non-dreamcatcher account
# Except in production.
class SafeEmailInterceptor
  def self.delivering_email(message)
    message.subject = "[#{Rails.env}] #{message.subject}"
    if !(message.to =~ /@dreamcatcher.net$/)
      message.to = "Email Test <mail-test@dreamcathcer.net>"
    end
  end
  
end


ActionMailer::Base.register_interceptor(SafeEmailInterceptor) unless Rails.env.production?
