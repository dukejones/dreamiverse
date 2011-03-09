class AdminMailer < ActionMailer::Base
  default :to => "feedback@dreamcatcher.net"
  
  def feedback_email(user, feedback)
    @user = user
    @feedback = feedback[:body]
    feedback_type = feedback[:type] + (feedback[:type]=='bug') ? ' // ' + feedback[:bug_type] : ''
    
    mail(from: user.email, subject: "Feedback: #{feedback_type}")
  end
end
