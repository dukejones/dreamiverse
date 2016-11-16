require 'rails_helper'

RSpec.describe ImageProfiles, :type => :model do
  before do
    setup_test_public_dir

    @test_file = File.join(TEST_FILE_PATH, '1f004.png') # 64x64 PNG

    Image.profile(:test_profile) do |img, options|
      img.minify # shrink 50%
    end
    
    @image = build(:image)
    @image.intake_file(@test_file)
  end
  after do
    empty_test_public_dir
  end

  context "#profile" do
    it "adds an entry to the profiles class variable" do
      Image.profile(:test_profile2) { } # empty block
      expect( Image.profiles.keys ).to include(:test_profile2)
    end
  end
  context "#generate_profile" do

    it "transforms an image according to a profile" do
      @image.generate_profile( :test_profile )

      img = @image.magick_image(:test_profile) # get the image, measure its size.
      expect( img.columns ).to eq(32) # half of 64
    end
    it "caches the resized image file" do
      expect( File.file?(@image.file_path(:test_profile)) ).to eq(false)
      @image.generate_profile( :test_profile )
      expect( File.file?(@image.file_path(:test_profile)) ).to eq(true)
    end

    it "works on a real profile" do
      expect{ !@image.profile_generated?(:header) }
      @image.generate_profile( :header )
      expect{ @image.profile_generated?(:header) }
    end
  end

  context "defined method" do
    it "works" do
      expect( File.file?(@image.file_path(:test_profile)) ).to eq(false)
      @image.test_profile
      expect( File.file?(@image.file_path(:test_profile)) ).to eq(true)
    end
  end

end