module UsersHelper

  def dreamstar_image_tag(rank)
    images = [
      "dreamstars-1-128.png",
      "dreamstars-2-128.png",
      "dreamstars-3-128.png",
      "dreamstars-4-128.png",
      "dreamstars-5-128.png",
      "dreamstars-6-128.png"
    ]
    raw( image_tag("dreamstars/#{images[rank-1]}") )
  end
end
