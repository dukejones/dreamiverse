
namespace :image do
  namespace :resize do
    desc "generate the default image sizes"
    task :defaults => :environment do
      default_sizes = %w(62x62 100x100 126x126 256x256)
      Image.all.each do |image|
        default_sizes.each do |size|
          image.resize size
        end
      end
    end
  end
end
