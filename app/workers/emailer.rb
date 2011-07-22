class Emailer
  @queue = :emailer_queue

  def self.perform(serialized_email)
    email = Marshal.load(serialized_email)
    email.deliver
  end
end