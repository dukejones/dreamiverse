class UserMailer < ActionMailer::Base
  default :from => "dreamcatcher.net <accounts@dreamcatcher.net>"

  helper do
    # TODO: patch Rails' url_for to work correctly with a string & :only_path => false
    def host_url_for(url_path)
      host = url_path[0] == '/' ? root_url.chop : root_url
      host + url_path
    end
  end
  
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
  
  # Give a 30 day warning that their username is too long

  def warn_long_username_email(user)
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: "Dreamcatcher.net account update")
  end  
  
  # Inform user that their new username request was received and applied 
  def long_username_request_updated(user)
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: "Dreamcatcher.net account update")
  end
  
  # Inform user that we did not hear from them regarding their new username within 30 days
  # of our email warning so their new username has been set to: 
  def long_username_updated(user)
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: "Dreamcatcher.net account update")
  end  

end

