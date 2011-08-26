class User::RegistrationsController < ApplicationController
  layout 'home'

  def new
    redirect_to :root and return if current_user
    
    @user = User.new
    
    render "users/join"
  end

  def forgot_password
    redirect_to :root and return if current_user
    
    render "users/forgot_password"
  end
  
  def send_password_reset
    @user = User.where(email: params[:email]).first
    if @user
      UserMailer.password_reset_email( @user ).deliver
      #Resque.enqueue(Emailer, reset_email)
      
      flash.notice = "password reset request sent to #{params[:email]}."
      redirect_to root_path
    else
      flash.alert = "email #{params[:email]} is not known within the dreamcatcher system."
      redirect_to forgot_password_path
    end
  end
  
  def reset_password
    @user = User.where(username: params[:username]).first
    @code = params[:reset_code]

    if @user.password_reset_code != @code
      redirect_to forgot_password_path, alert: 'that reset code is no longer valid.' and return
    end
    render "users/reset_password"
  end
  
  def do_password_reset
    @user = User.find(params[:id])
    @code = params[:reset_code]

    if @user.password_reset_code != @code
      redirect_to root_path, alert: 'that is an invalid reset code.' and return
    end

    if @user.update_attributes( params[:user] )
      redirect_to login_path, notice: "your password has been reset."
    else
      # I would like a better way to pass model errors back to the template.
      redirect_to reset_password_path(@user.username, @code, errors: @user.errors.full_messages.join('<br>')), 
        alert: "we could not reset your password."
    end
  end
  
  def create
    # creates a user with an email / password.
    params[:user][:seed_code] = session[:seed_code] unless params[:user].has_key?(:seed_code)
    
    @user = User.new(params[:user])
    raise ActiveRecord::RecordInvalid.new(@user) unless (@captcha = verify_recaptcha)
    @user.save!
  
    set_current_user @user
    # XXX: This is slow!  Do this in the background.
    UserMailer.welcome_email(@user).deliver
    
    if auth_provider = session.delete(:registration_auth_provider)
      redirect_to "/auth/#{auth_provider}"
    else
      redirect_to :root, :notice => "welcome, dreamer."
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    # TODO: display these on the join page
    # params[:user].delete(:password)
    # params[:user].delete(:password_confirmation)
    # flash[:user_errors] = @user.errors || []
    # flash[:user_errors] << "" unless verify_recaptcha
    # redirect_to join_path(user: params[:user]), :alert => "could not create the user."
    errors = @user.errors.full_messages
    # Captcha verification & error adding would be cleaner in the model.
    errors << "captcha error: the captcha entered was incorrect" unless @captcha
    flash.now[:alert] = "we could not create this user:<br>" + errors.join('<br>')
    render "users/join"
  end
  
  # def update
  #   # adds email / password to existing user.    
  # end
end