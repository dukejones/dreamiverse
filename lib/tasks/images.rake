namespace :image do
  desc 'generate all commonly used images for main/avatar/bedsheets'
  task :resize => ['image:resize:main','image:resize:avatar','image:resize:bedsheet']

  namespace :resize do
    desc 'for each entry main image, generate header, stream_header and dreamfield_header'   
    task :main => :environment do      
      Entry.where(:main_image_id ^ nil).where(:created_at > 30.days.ago).each do |entry|
        begin
          image = entry.main_image
      
          generated = []
          [:header, :stream_header, :dreamfield_header, :thumb].each do |profile|
            generated << profile.to_s if image.pre_generate(profile)
          end

          thumb_sizes = [64]
          thumb_sizes.each do |size|
            generated << "thumb-#{size}" if image.pre_generate(:thumb, {size: size})
          end
        
          log "Generated (id: #{image.id}) #{image.title}: #{generated.join(' ')}" unless generated.blank?
        rescue => e
          log "Invalid Image! #{image.id} #{image.filename}", :error
        end
      end
    end
  
    desc 'for each avatar image, generate avatar_main, avatar_medium and most popular sizes (32/64)'  
    task :avatar => :environment do      
      Image.joins(:users).each do |image|
        begin
          generated = []
          [:avatar, :avatar_main, :avatar_medium].each do |profile|
            generated << profile.to_s if image.pre_generate(profile)
          end
      
          extra_sizes = [32, 64]
          extra_sizes.each do |size|
            generated << "avatar-#{size}" if image.pre_generate(:avatar, :size => size)
          end               
          log "Generated for avatar (id: #{image.id}) #{image.title}: #{generated.join(' ')}" unless generated.blank?
        rescue => e
          log "Invalid Image! #{image.id} #{image.filename}", :error
        end
      end
    end
    
    desc 'for each bedsheet generate a jpg'
    task :bedsheet => :environment do
      Image.where(:section => 'Bedsheets').each do |image|
        generated = []
        generated << "bedsheet" if image.pre_generate(:bedsheet, :format => 'jpg')
        generated << 'default thumb' if image.pre_generate(:thumb, :format => 'jpg')
        generated << 'thumb 120' if image.pre_generate(:thumb, :size => 120, :format => 'jpg')

        log "Generated for bedsheet (id: #{image.id}) #{image.title} JPGs: #{generated.join(' ')}" unless generated.blank?
      end
    end
  end
  
  desc 'associate whats with image bank tag images'
  task :link_whats_to_tag_images => :environment do
    Image.where(section: 'Tag').each do |image|
      what = What.for(image.title)
      next if what.image_id
      what.image = image
      what.save!
      log "Added Tag Image: #{image.title}"
    end
  end

  desc 'test out an image profile'
  task :test_profile => :environment do
    image_id = ENV['id']
    profile  = ENV['profile']
    image    = Image.find image_id

    image.generate(profile)

    `open #{image.file_path(profile)}`
  end

  desc 'migrate images from old id-based storage to new date-based directories'
  task :migrate_files => :environment do
    old_imagebank_dir = ENV['old_imagebank']

    Image.find_each do |image|
      # next if image[:format].blank?
      legacy_filename = "#{image.id}.#{image[:format]}"
      orig_file = File.join(old_imagebank_dir, legacy_filename)
      if !File.file?(orig_file)
        if image.entries.blank?
          image.destroy
          puts "Destroyed image ##{image.id}: #{image.original_filename}"
          next
        else
          puts "Could not find file #{orig_file}.  Existing: " + Dir[File.join(old_imagebank_dir, "#{image.id}*")].inspect
          puts "Image referenced in dreams: " + image.entries.map{|e| [e.id, e.title]}.inspect
          raise "undealt-with orphan file"
        end
      end

      tmpfile = "/tmp/#{image.original_filename}"
      FileUtils.mv orig_file, tmpfile
      image.intake_file(tmpfile)
      FileUtils.mv tmpfile, orig_file
    end
  end
  
end
