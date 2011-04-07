
namespace :app do

  task :starlight => ['app:starlight:snapshot', 'app:starlight:entropize']

  namespace :starlight do
    desc "Entropize all Starlight"
    task :entropize => :environment do
      begin_time = Time.now
      log("Entropizing all starlight")
      
      [Entry, User, What].each do |starlit_class|
        starlit_class.where("starlight > 0").each do |entity|
          entity.entropize!
        end
      end

      log("Total time: #{Time.now - begin_time}")
    end
    
    desc "Take the nightly historical snapshot of all starlight"
    task :snapshot => :environment do
      log("Snapshotting all starlight")
      [Entry, User, What].each do |starlit_class|
        starlit_class.where("starlight > 0").each do |entity|
          Starlight.snapshot( entity )
        end        
      end
    end
  end
  
 
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

end

namespace :fix do
  desc "Eliminate duplicate What tags"
  task :duplicate_whats => :environment do
    dupe_names = What.group('name').having('count(name) > 1').count.keys
    log("Resolving #{dupe_names.count} duplicates.")
    dupe_names.each do |name|
      whats = What.where(name: name)
      # move all tags associated with the other whats to the last what.
      # then delete the empty whats.
      last_what = whats.pop
      whats.each do |what|
        what.tags.each do |tag|
          if tag.entry.nil?
            log "tag associated with deleted entry."
            tag.destroy
          else
            log "#{what.name} - #{tag.entry.title}"
            tag.update_attribute(:noun_id, last_what.id)
          end
        end
        what.destroy
      end

      # if none of the whats had any tags at all, just delete them all.
      if last_what.tags.empty?
        last_what.destroy
      end
    end
  end
end

def log(msg)
  Rails.logger.info(msg)
  puts msg
end