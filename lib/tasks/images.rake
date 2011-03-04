namespace :image do
  
  namespace :main do
    desc 'for each entry main image, generate header, stream_header and dreamfield_header'   
    task :all => :environment do      
      Entry.where(:main_image_id ^ nil).map do |entry|
        image = Image.find_by_id(entry.main_image.id)
        puts "processing main images for (id: #{image.id}) #{image.title}.."
        
        puts 'header'
        image.generate_profile(:header)
        puts 'stream'
        image.generate_profile(:stream_header)
        puts 'dream field header'
        image.generate_profile(:dreamfield_header)
        puts 'default thumb' 
        image.generate_profile(:thumb)
            
        thumb_sizes = %w(64 120 122)
        puts 'extra thumbs:'
        options = {}
        thumb_sizes.each do |size|
          puts size
          options[:size] = size
          image.generate_profile(:thumb,options)
        end
      end
      puts 'Done main images.'
    end
  end
    
  namespace :avatar do
    desc 'for each avatar image, generate avatar_main, avatar_medium and most popular sizes (32/64)'  
    task :all => :environment do      
      Image.where(:title ^ 'Default Avatar',:section => 'Avatar').map do |image|
        puts "processing avatar images for (id: #{image.id}) #{image.title}.."
        
        puts 'avatar'
        image.generate_profile(:avatar)        
        puts 'avatar main'
        image.generate_profile(:avatar_main)
        puts 'avatar medium'
        image.generate_profile(:avatar_medium)
        
        custom_sizes = %w(32x32 64x64)
        puts "Resizing #{image.title}:"
        custom_sizes.each do |size|
          puts size
          image.resize size
        end               
      end
      puts 'Done avatar images.'
    end        
  end
    
  namespace :bedsheet do
    desc 'for each bedsheet generate a jpg'
    task :all => :environment do
      Image.where(:section => 'Bedsheets').map do |image|
        puts "processing bedsheet jpg (id: #{image.id}) #{image.title}.."
        image.generate_profile(:bedsheet, :format => 'jpg')
      end
    end
  end
  
  task :generate_all => ['image:main:all','image:avatar:all','image:bedsheet:all'] 
end
