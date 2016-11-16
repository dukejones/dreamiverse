require 'rails_helper'

RSpec.describe Image, :type => :model do
  before do
    setup_test_public_dir
  end
  after do
    empty_test_public_dir
  end

  context "#set_metadata" do

    it "saves metadata after intaking a file" do
      # pending 'after file import metadata format updating will be reinstated'
      @test_file = File.join(TEST_FILE_PATH, '1f004.png') # 64x64 PNG
      image = build(:image)
      image.intake_file @test_file

      expect(image.width).to eq(64)
      expect(image.height).to eq(64)
      # expect(image.format).to eq("PNG")
      expect(image.size).to eq(1530)
    end
  end
end
