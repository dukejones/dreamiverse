class UserMailer < ActionMailer::Base
  default :from => "dreamcatcher <accounts@dreamcatcher.net>"
  
  def welcome_email(user)
    @user = user
    #"http://#{HOST}/user/confirm/#{user.confirmation_code}"
    @confirmation_url = confirm_user_url(@user.id, @user.confirmation_code, host: 'localhost:3000')
    mail(to: "#{@user.name} <#{@user.email}>", subject: "welcome to dreamcatcher")
  end
  
  def password_reset(email)
    @email = email
    # @reset_url = reset_password_url(email, sha1('randomness'))
    @reset_url = "http://nowhere.com"
    mail(to: email, subject: "dreamcatcher :: password reset request")
  end
end
