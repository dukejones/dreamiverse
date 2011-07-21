class Emailer
  @queue = :send_email_queue

  def self.perform(serialized_email)
    email = Marshal.load(serialized_email)
    ActionMailer::Base.wrap_delivery_behavior email
    email.deliver
  end
end