module UsersHelper
  DreamstarImages = [
    "dreamstars-1-128.png",
    "dreamstars-2-128.png",
    "dreamstars-3-128.png",
    "dreamstars-4-128.png",
    "dreamstars-5-128.png",
    "dreamstars-6-128.png"
  ]
  def dreamstar_image_tag(rank)
    raw( image_tag("dreamstars/#{DreamstarImages[rank-1]}", :size => '128x128') )
  end
  def client_browser_name
    user_agent = request.env['HTTP_USER_AGENT'].downcase
    if user_agent =~ /msie/i
            "Internet Explorer"
    elsif user_agent =~ /ipad/i
            "IPad"
    elsif user_agent =~ /gecko/i
            "Mozilla"
    elsif user_agent =~ /opera/i
            "Opera"
    elsif user_agent =~ /applewebkit/i
            "Safari"
    else
            "Unknown"
    end
  end 
end
