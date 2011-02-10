require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  setup :mock_magick_image, :mock_set_metadata

  test "image create sets metadata" do
    @image = Image.make
    mock_image = mock("magick_image", {width: 128, height: 256, size: 1024})
    @image.stubs(:magick_image).returns(mock_image)
  end
  
  test "dream_header profile" do
    mock_image = mock("magick_image")

    @image = Image.make
    # @image.stubs(:magick_image).returns(mock_image)
    debugger
    @image.path
    
  end

  def mock_magick_image
    mock_image = mock("magick_image")
    Image.any_instance.stubs(:magick_image).returns(mock_image)
  end
  
  def mock_set_metadata
    
  end
end

