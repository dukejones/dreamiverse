class UserMailer < ActionMailer::Base
  default :from => "Dreamcatcher <accounts@dreamcatcher.net>"
  
  def welcome_email(user)
    @user = user
    #"http://#{HOST}/user/confirm/#{user.confirmation_code}"
    @confirmation_url = confirm_user_url(@user.id, @user.confirmation_code, host: 'localhost:3000')
    mail(to: 'Duke Dorje <duke@dreamcatcher.net>', subject: "Welcome to Dreamcatcher")
  end
end
