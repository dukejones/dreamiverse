
namespace :app do
 
  namespace :tagcloud do
    desc "Generate all tags"
    task :generate => :environment do
      begin_time = Time.now
      log("---Generating all tag clouds---")
      Entry.all.map do |e| 
        next if e.tags.count >= 15
        pre_tags = e.tags.count
        Tag.auto_generate_tags(e) 
        e.reorder_tags 
        log("id: #{e.id} pre:#{pre_tags} post:#{e.tags.count}")
      end    
      log("Total time: #{Time.now - begin_time}")
    end
  end

  task :ping => :environment do
    host = ActionMailer::Base.default_url_options[:host]
    port = ActionMailer::Base.default_url_options[:port]
    url = "http://#{host}"
    url += ":#{port}" unless port.blank? || port == 80
    puts "Pinging the app #{url}."
    open(url)
  end

end

task :compile => ['barista:brew', 'compile:sass', 'compile:jammit']
namespace :compile do
  desc "Build all application sass"
  task :sass => :environment do
    log "Compiling Sass Stylesheets."
    # Sass::Plugin.on_updating_stylesheet {|template, css| puts "compiling #{template} to #{css}" }
    Sass::Plugin.update_stylesheets
  end

  desc "Compile and compress all assets with Jammit"
  task :jammit => :environment do
    log "Packaging assets with Jammit."
    Jammit.package!
  end

end

