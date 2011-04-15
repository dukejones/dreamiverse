require 'test_helper'


class ImageImporterTest < ActiveSupport::TestCase
  LegacyImageDir = Legacy::Image::Dir
  
  def setup
    @tmp_upload_dir = 'tmp/uploads'
    FileUtils.mkdir_p "#{Rails.root}/#{@tmp_upload_dir}/originals"
    Image.const_set('UPLOADS_PATH', "../#{@tmp_upload_dir}")
  end
  
  def teardown
    FileUtils.remove_dir(@tmp_upload_dir, true)
  end
  
  test 'image import' do
    image = Legacy::Image.valid[60]
    new_image = Migration::ImageImporter.new(image).migrate
    new_image.save!
    
    new_file = open(new_image.path)
    old_file = open("#{LegacyImageDir}/#{image.path}")
    
    assert_equal new_image.original_filename, image.filename
    assert_equal new_file.size, old_file.size
  end
  
  test "legacy image 62" do
    image = Legacy::Image.find 62
    new_image = Migration::ImageImporter.new(image).migrate
    new_image.save!
    debugger
    1
  end
  
  test "corresponding_object" do
    image = Legacy::Image.valid[100]
    im = image.find_or_create_corresponding_image
    
    assert_equal im, image.corresponding_object
  end
end
