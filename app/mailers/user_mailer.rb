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
end
