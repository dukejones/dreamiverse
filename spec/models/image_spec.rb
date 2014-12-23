require 'rails_helper'

RSpec.describe Image, :type => :model do
  TEST_FILE_PATH = File.join(Rails.root, 'spec', 'test_files')
  TEST_PUBLIC_DIR = File.join(Rails.root, 'tmp', 'test_public')


  context ImageFileManager do
    before do
      setup_test_public_dir

      @test_file = File.join(TEST_FILE_PATH, '1f004.png')
    end
    after do
      empty_test_public_dir
    end

    it "copies the file we give it into the image uploads directory" do
      image = build(:image)
      upload_path = image.generate_full_upload_path(@test_file)

      image.intake_file @test_file
      expect( File.file?(upload_path) ).to eq(true)
    end

    it "avoids name collisions on files" do
      image = build(:image)

      # copy file of same name to force a collision
      first_upload_path = image.generate_full_upload_path(@test_file)
      upload_dir = File.dirname(first_upload_path)
      FileUtils.mkdir_p(upload_dir)
      FileUtils.cp(@test_file, upload_dir)

      # intake the file of same name
      second_upload_path = image.generate_full_upload_path(@test_file)
      image.intake_file(@test_file)
      # test that file name has an appended '-001'
      expect( File.basename(image.image_path) ).to match(/\-001\.png/)
    end

    it "generates the path to the original file" do
      image = build(:image)
      image.intake_file(@test_file)

      expect( image.file_path ).to eq(image.image_path)
    end

    it "generates the path to a resized profile" do
      image = build(:image)
      image.intake_file(@test_file)

      expect( image.file_path(:header) ).to include(Image::CACHE_DIR)
      expect( image.file_path(:header) ).to match(/\-header\.png/)
    end
  end


  def setup_test_public_dir
    FileUtils.mkdir_p(TEST_PUBLIC_DIR)
    allow(Rails).to receive(:public_path) { TEST_PUBLIC_DIR }
  end

  def empty_test_public_dir
    FileUtils.rm_r(TEST_PUBLIC_DIR)
  end
end
