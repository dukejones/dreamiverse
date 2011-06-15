module ApplicationHelper
  def avatar_image(user, size = :main)
    avatar_image = user._?.image || Image.default_avatar
    case size
    when :main
      avatar_image.url('avatar_main')
    when :medium
      avatar_image.url('avatar_medium')
    else
      avatar_image.url('avatar', :size => size)
    end
  end
  
  def friend_icon_tag(relationship, size, html_options={})
    html_options.merge!( size: "#{size}x#{size}", alt: relationship )
    image_tag( "icons/#{friend_icon(relationship, size)}", html_options)
  end
  
  def friend_icon(relationship, size)
    case relationship
    when :friends
      "friend-#{size}.png"
    when :following
      "friend-#{size}-follow.png"
    when :followed_by
      "friend-#{size}-follower.png"
    when :none
      "friend-#{size}-none.png"
    end
  end

  def follow_action(relationship)
    case relationship
    when :friends, :following
      "unfollow"
    when :followed_by, :none
      "follow"
    end
  end
  
  def is_ipad?
    request.user_agent._?.match(/iPad/)
  end
  
  # Note: this depends on a "global" variable @entry being set
  def bedsheet_style

    if request.path == dreamstars_path || request.path == search_user_path
      bedsheet_url = "/images/bedsheets/dreamstars-aurora-hi.jpg" 
    else
      # if user has ubiquity mode, use user's bedsheet no matter what
      # Not yet implemented.
      bedsheet_image ||= @entry._?.view_preference._?.image
      bedsheet_image ||= @user._?.view_preference._?.image
      bedsheet_image ||= current_user._?.view_preference._?.image

      if is_mobile?
        bedsheet_url = bedsheet_image._?.url(:bedsheet_small, :format => 'jpg')
      else
        bedsheet_url = bedsheet_image._?.url(:bedsheet, :format => 'jpg')
      end
      bedsheet_url ||= "/images/bedsheets/aurora_green-lo.jpg"
    end
    "background-image: url(#{bedsheet_url})"
  end

  def bedsheet_attachment
    bedsheet_attachment ||= @entry._?.view_preference._?.bedsheet_attachment
    bedsheet_attachment ||= @user._?.view_preference._?.bedsheet_attachment
    bedsheet_attachment ||= current_user._?.view_preference._?.bedsheet_attachment
    bedsheet_attachment ||= "scroll"
    bedsheet_attachment
  end
  
  def menu_style
    return nil unless current_user
    current_user.view_preference.menu_style
  end
  
  def font_size
    return nil unless current_user

    case current_user.view_preference.font_size
    when 'large' then 'fontLarge'
    when 'medium' then 'fontMedium'
    when 'small' then 'fontSmall'
    end
  end
  
  def theme
    theme ||= @entry._?.view_preference._?.theme
    theme ||= @user._?.view_preference._?.theme
    theme ||= current_user._?.view_preference._?.theme
    theme ||= "light"
    theme
  end

  def appearance_classes
    "#{theme} #{bedsheet_attachment} #{menu_style} #{font_size}"
  end

end
