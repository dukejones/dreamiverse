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
  def friends_header_image
    img_url = case @mode
    when "friends"
      "/images/icons/friend-64.png"
    when "following"
      "/images/icons/friend-follow-64.png"
    when "followers"
      "/images/icons/friend-follower-64.png"
    else
      "/images/icons/friend-64.png"
    end
    
    raw( img_url )
  end
end
