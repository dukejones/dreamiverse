require 'rails_helper'

RSpec.describe Image, :type => :model do
  context "metadata" do
    before do
      setup_test_public_dir
      @test_file = File.join(TEST_FILE_PATH, '1f004.png') # 64x64 PNG
    end
    after do
      empty_test_public_dir
    end

    it "saves metadata after intaking a file" do
      image = build(:image)
      image.intake_file @test_file

      expect(image.width).to eq(64)
      expect(image.height).to eq(64)
      expect(image.format).to eq("PNG")
      expect(image.size).to eq(1530)
    end
  end
end
