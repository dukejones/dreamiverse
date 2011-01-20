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
end
