class UsersController < ApplicationController
  def index
    @top_images = [
      "", # so its index starts at 1
      "dreamstars-1-128.png",
      "dreamstars-2-128.png",
      "dreamstars-3-128.png",
      "dreamstars-4-128.png",
      "dreamstars-5-128.png",
      "dreamstars-6-128.png"
    ]

    @users = User.all
  end

  def friends
    @user = 
      if params[:username]
        User.find_by_username(params[:username]) # || raise "User #{params[:username]} does not exist."
      else
        current_user
      end
    @mode = params[:mode] 
    @friends = case @mode
      when 'friends'   then @user.friends
      when 'following' then @user.following
      when 'followers' then @user.followers
    end
  end
  
  def follow
    if request.xhr?
      user = User.find(params[:user_id])
    else
      user = User.find_by_username(params[:username])
    end

    case params[:verb]
      when 'follow' then current_user.following << user unless current_user.following?(user)
      when 'unfollow' then current_user.following.delete user if current_user.following?(user)
    end
    
    respond_to do |format|
      format.html { redirect_to entries_path(user.username) }
      format.json { render :json => {message: 'success'} }
    end
  end
  
  def bedsheet
    @user = User.find(params[:id])
    @user.view_preference.image = Image.find(params[:bedsheet_id])
    @user.save!
    render :json => "user bedsheet updated"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end
end
