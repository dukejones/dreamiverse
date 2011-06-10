class UserMailer < ActionMailer::Base
  default :from => "dreamcatcher.net <accounts@dreamcatcher.net>"
  
  def welcome_email(user)
    @user = user
    #"http://#{HOST}/user/confirm/#{user.confirmation_code}"
    @confirmation_url = confirm_user_url(@user.id, @user.confirmation_code)
    mail(to: "#{@user.name} <#{@user.email}>", subject: "Welcome to dreamcatcher.net")
  end
  
  def password_reset_email(user)
    @user = user
    @reset_url = reset_password_url(user.username, user.password_reset_code)
    mail(to: "#{user.name} <#{user.email}>", subject: "Password reset")
  end

  def warn_long_username_email(user)
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: "Dreamcatcher.net account update")
  end  
  
end
