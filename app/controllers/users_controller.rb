class UsersController < ApplicationController
  def index
    @top_images = [
      "dreamstars-1-128.png",
      "dreamstars-2-128.png",
      "dreamstars-3-128.png",
      "dreamstars-4-128.png",
      "dreamstars-5-128.png",
      "dreamstars-6-128.png"
    ]

    @users = User.all
  end

  def update
    @user = current_user # User.find params[:id]
    # raise "access denied" unless @user == current_user
    if params[:new_location]
      @user.wheres << Where.create(params[:new_location])
    end
    
    @user.update_attributes(params[:user])
    @user.save
    respond_to do |format|
      format.html { render :text => "user updated" }
      format.json { render :json => {:message => 'user updated'}}
    end
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
  
  # XHR only
  def bedsheet
    @user = current_user
    @user.view_preference.update_attribute(:image, Image.find(params[:bedsheet_id]))
    render :json => "user bedsheet updated"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end
  
  # XHR only.
  def avatar
    @image = Image.new({
      section: 'Avatar',
      incoming_filename: params[:qqfile],
      uploaded_by: current_user
    })
    @image.save!
    @image.write(request.body.read)

    current_user.update_attribute(:image, @image)
    render :json => { :avatar_path => @image.url('avatar_main'), :avatar_thumb_path => @image.url(:avatar, :size => 32), :avatar_image => @image }
  end
end
