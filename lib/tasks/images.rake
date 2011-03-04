namespace :image do
  namespace :main do
    task :default => :generate_header
    desc "for each entries main image generate header/stream_header and dreamfield_header"
    task :generate_header => :environment do
      # for each entries main image generate header, stream_header and dreamfield_header      
      Entry.where(:main_image_id ^ nil).map do |entry|
        puts "generating header image for main_image.id #{entry.main_image.id}"
        # image.generate_profile(:main_image)
      end
      puts "Done."
    end  
    task :all => ["image:main:generate_header"]   
  end
end

=begin
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
=end