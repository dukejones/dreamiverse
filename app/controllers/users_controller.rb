class UsersController < ApplicationController
  def index
    @top_images = [
      "", # so its index starts at 1
      "small-stellated-dodecahedron-DS1-128.png",
      "great-icosahedron-DS2-128.png",
      "small-ditrigonal-icosidodecahedron-DS3-128.png",
      "great-icosahedron-DS4-128.png",
      "small-ditrigonal-icosidodecahedron-DS5-128.png",
      "great-icosahedron-DS6.png"
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
  
  # ajax only
  def follow
    user = User.find(params[:user_id])
    case params[:verb]
      when 'follow' then current_user.following << user
      when 'unfollow' then current_user.following.delete user
    end
    render :json => {message: 'success'}
  end
end
