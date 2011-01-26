
namespace :image do
  namespace :resize do
    desc "generate the default image sizes"
    task :defaults => :environment do
      default_sizes = %w(64x64 128x128 256x256 720x720 720x200)
      Image.all.each do |image|
        puts "Resizing #{image.title}:"
        default_sizes.each do |size|
          puts size
          image.resize size
        end
        puts "Done."
      end
    end
  end
end
