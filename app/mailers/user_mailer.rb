class UserMailer < ActionMailer::Base
  default :from => "accounts@dreamcatcher.net"
  
  def welcome_email(user)
    @user = user
    #"http://#{HOST}/user/confirm/#{user.confirmation_code}"
    @confirmation_url = url_for(confirm_user_path(@user.id, @user.confirmation_code))
    mail(to: 'duke@dreamcatcher.net', subject: "Welcome to Dreamcatcher")
  end
end
