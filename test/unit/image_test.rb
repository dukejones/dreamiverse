require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  setup :mock_magick_image, :mock_set_metadata

  # test "image create sets metadata" do
  #   @image = Image.make
  #   mock_image = mock("magick_image", {width: 128, height: 256, size: 1024})
  #   @image.stubs(:magick_image).returns(mock_image)
  # end
  # 
  # test "dream_header profile" do
  #   mock_image = mock("magick_image")
  # 
  #   @image = Image.make
  #   # @image.stubs(:magick_image).returns(mock_image)
  #   @image.path
  #   
  # end

  test 'default filename has format of original file, specifying format option changes it' do
    @image = Image.make(:incoming_filename => 'image.jpg')
    assert_equal 'jpg', @image.format
    assert_equal 'jpg', @image.filename.split('.').last
    assert_equal 'png', @image.filename(nil, :format => 'png').split('.').last
    assert_match /\d+-thumb-32\.png/, @image.filename(:thumb, :format => 'png', :size => 32)
  end
  
  def mock_magick_image
    mock_image = mock("magick_image")
    Image.any_instance.stubs(:magick_image).returns(mock_image)
  end
  
  def mock_set_metadata
    
  end


  describe 'writing files' do
    def setup
      @tmp_upload_dir = 'tmp/uploads'
      FileUtils.mkdir_p "#{Rails.root}/#{@tmp_upload_dir}/originals"
      Image.const_set('UPLOADS_PATH', "../#{@tmp_upload_dir}")
    end

    def teardown
      FileUtils.remove_dir(@tmp_upload_dir, true)
    end
  end
end

