namespace :image do
  namespace :main do
    desc "for each entry with a main image set, generate header, stream_header and dreamfield_header"   
    task :generate_header => :environment do      
      Entry.where(:main_image_id ^ nil).map do |entry|
        image = Image.find_by_id(entry.main_image.id)
        puts "generating header image for main_image.id #{image.id}..."
        image.generate_profile(:header)
        puts "generating stream header image for main_image.id #{image.id}..."
        image.generate_profile(:stream_header)
        puts "generating dream field header image for main_image.id #{image.id}..."
        image.generate_profile(:dreamfield_header)
      end
      puts 'Done.'
    end
    task :popular => ["image:main:generate_header"] 
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