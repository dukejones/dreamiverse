namespace :image do
  desc 'generate all commonly used images for main/avatar/bedsheets'
  task :resize => ['image:resize:main','image:resize:avatar','image:resize:bedsheet']

  namespace :resize do
    desc 'for each entry main image, generate header, stream_header and dreamfield_header'   
    task :main => :environment do      
      Entry.where(:main_image_id ^ nil).each do |entry|
        # image = Image.find_by_id(entry.main_image.id)
        image = entry.main_image
        log "Main Images for (id: #{image.id}) #{image.title}:"
      
        log 'header' if image.pre_generate(:header)
        log 'stream' if image.pre_generate(:stream_header)
        log 'dream field header' if image.pre_generate(:dreamfield_header)
        log 'default thumb' if image.pre_generate(:thumb)

        thumb_sizes = [64, 120, 122]
        thumb_sizes.each do |size|
          log "thumb #{size}" if image.pre_generate(:thumb, {size: size})
        end
      end
      log 'Done main images.'
    end
  
    desc 'for each avatar image, generate avatar_main, avatar_medium and most popular sizes (32/64)'  
    task :avatar => :environment do      
      Image.where(:title ^ 'Default Avatar',:section => 'Avatar').each do |image|
        log "processing avatar images for (id: #{image.id}) #{image.title}.."
      
        log 'avatar' if image.pre_generate(:avatar)        
        log 'avatar main' if image.pre_generate(:avatar_main)
        log 'avatar medium' if image.pre_generate(:avatar_medium)
      
        extra_sizes = [32, 64]
        log "Resizing Avatar: #{image.title}:"
        extra_sizes.each do |size|
          log size if image.pre_generate(:avatar, :size => size)
        end               
      end
      log 'Done avatar images.'
    end        
    
    desc 'for each bedsheet generate a jpg'
    task :bedsheet => :environment do
      Image.where(:section => 'Bedsheets').each do |image|
        log "(id: #{image.id}) #{image.title} JPGs:"
        log "bedsheet" if image.pre_generate(:bedsheet, :format => 'jpg')
        log 'default thumb' if image.pre_generate(:thumb, :format => 'jpg')
        log 'thumb 120' if image.pre_generate(:thumb, :size => 120, :format => 'jpg')
      end
    end
  end
  
  desc 'associate whats with image bank tag images'
  task :link_whats_to_tag_images => :environment do
    Image.where(section: 'Tag').each do |image|
      what = What.for(image.title)
      next if what.image_id
      pp "processing image: #{image.title}"
      what.image = image
      what.save!
    end
  end
  
end
