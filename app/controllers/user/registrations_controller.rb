class User::RegistrationsController < ApplicationController
  layout 'home'

  def new
    redirect_to :root and return if current_user
    
    @user = User.new(params[:user])
    
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
    
    if verify_recaptcha
      @user = User.create(params[:user])
      if @user.valid? # && verify_recaptcha
        set_current_user @user
      
        UserMailer.welcome_email(@user).deliver
      
        if auth_provider = session.delete(:registration_auth_provider)
          redirect_to "/auth/#{auth_provider}"
        else
          redirect_to :root, :notice => "welcome, dreamer."
        end
      else
        # TODO: display these on the join page
        # params[:user].delete(:password)
        # params[:user].delete(:password_confirmation)
        # flash[:user_errors] = @user.errors || []
        # flash[:user_errors] << "" unless verify_recaptcha
        # redirect_to join_path(user: params[:user]), :alert => "could not create the user."
        flash.now[:alert] = "We could not create this user.<br>" + @user.errors.full_messages.join('<br>')
        render "users/join"
      end
    else
      flash.now[:alert] = "Invalid Captcha text"
      render "users/join"    
    end
  end
  
  def update
    # adds email / password to existing user.    
  end
end