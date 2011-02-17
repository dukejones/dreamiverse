module ApplicationHelper
  def avatar_image(user, size = :main)
    avatar_image = user.image
    case size
    when :main
      avatar_image.url('avatar_main')
    when :medium
      avatar_image.url('avatar_medium')
    else
      avatar_image._?.url('avatar', size) || 'images/uploads/1-avatar-64.jpg'
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
      "friend-follow-#{size}.png"
    when :followed_by
      "friend-follower-#{size}.png"
    when :none
      "friend-none-#{size}.png"
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
  
  def coffeescript_include_tag(*sources)
    javascript_include_tag(*(sources.map { |js| "compiled/#{js}" }))
  end
  
  def sass_link_tag(*sources)
    stylesheet_link_tag(*(sources.map { |css| "compiled/#{css}" }))
  end

  def bedsheet_style
    bedsheet_attachment = 'scroll'
    # TODO: these should be an imagebank url.
    # if frontpage, use frontpage bedsheet
    bedsheet_url = "/images/bedsheets/air-04.jpg" if request.path == '/'
    # if dreamstars, use dreamstars bedsheet
    bedsheet_url = "/images/bedsheets/air-02.jpg" if request.path == '/dreamstars'
    # if user has ubiquity mode, use user's bedsheet no matter what
    # Not yet implemented.
    # if entry has a view preference, use entry's bedsheet
    bedsheet_url ||= @entry._?.view_preference._?.image._?.url
    # if user has a view preference, use user's bedsheet
    bedsheet_url ||= current_user._?.view_preference._?.image._?.url
    bedsheet_url ||= "/images/bedsheets/air-03.jpg"

    "background: url(#{bedsheet_url}) repeat #{bedsheet_attachment} 0 0"
  end
end
