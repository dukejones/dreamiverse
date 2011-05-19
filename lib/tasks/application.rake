
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
  desc "Fix any reference to yourself as your own friend"
  task :following_myself => :environment do
    Follow.where("user_id=following_id").each do |follow|
      log("Destroying user #{follow.user.username} following himself.")
      follow.destroy
    end
  end
  
  desc "Fix improperly detected image formats"
  task :bad_image_formats => :environment do
    Image.all.select{|i| !i.format || (i.format.length > 3 && i.format != 'jpeg')}.each do |i|
      begin
        log("Fixing image: #{i.id} - #{i.enabled ? 'enabled' : 'disabled'} - #{i.format} - #{i.original_filename}")
        i.format = i.original_filename.split('.').last.gsub(/\s/, '').downcase
        i.import_from_file(i.path, i.original_filename)
      rescue => e
        log("Error!! Image #{i.id}: #{e}")
      end
    end
  end
  
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

  desc "Split janked (period..dash--and comma) seperated whats into seperate whats and fix related entry what associations in tags table"
  task :janked_whats => :environment do
    janked_whats = What.where((:name.matches % '%,%') | (:name.matches % '%..%') | (:name.matches % '%--%'))
    
    log("Attempting to fix #{janked_whats.count} janked what(s)...") if janked_whats.count > 0
    total_fixed = 0
    
    janked_whats.each do |janked_what| 
      if janked_what.name =~ %r{(https?://|www\.)([-\w\.]+)+(:\d+)?(/([\w/_\.]*(\?\S+)?)?)?}
        log("#{janked_what.name} is a url. Deleting.")
        janked_what.tags.each {|tag| tag.destroy }
        janked_what.destroy
        next
      end

      if janked_what.name =~ /^[\d,]+$/ # test for and skip digital comma whats like: 10,000,000
        log("#{janked_what.name} is a comma-separated number.")
        next
      elsif janked_what.name =~ /,/
        regex = /,+/
      elsif janked_what.name =~ /\.\./
        regex = /\.+/ 
      elsif janked_what.name =~ /--/
        regex = /-+/
      else
        # It's fine.
        # log("#{janked_what.name} is fine.")
        next
      end
      
      log("Found janked what: #{janked_what.name}")
      
      single_what_names = janked_what.name.split(regex)
      
      related_tags = Tag.where(noun_id: janked_what.id)  
      log(related_tags.count > 0 ? "Fixing #{related_tags.count} tag(s)" : 'No related tags')
      
      related_tags.each do |tag|
        entry = tag.entry
        log("Found tag entry id: #{entry.id} name: #{tag.noun.name} kind: #{tag.kind}")
        
        # now add replacement single_what tags for entry
        single_what_names.each do |single_what_name|
          what = What.for single_what_name
          next if what.nil?
          entry.tags.create(noun: what, position: entry.tags.count, kind: tag.kind)
          log("Added what tag: #{what.name} for entry_id: #{entry.id}")
        end
        
        tag.destroy
        log("Deleted #{janked_what.name} from tags table for entry id: #{entry.id}")
        
        entry.reorder_tags
      end
      janked_what.destroy # delete janked what from what table
      log("Deleted #{janked_what.name} from whats table")
      total_fixed += 1
    end
    log("Total janked tags fixed: #{total_fixed}")
  end

  desc "Re-process all tags clouds that have blacklisted words"
  task :blacklisted_clouds => :environment do
    begin_time = Time.now
    fixed = 0
    log("---Looking for blacklisted tag clouds---")
    Entry.all.map do |entry|
      entry.what_tags.auto.each do |tag|
        if Tag::BlacklistWords[tag.noun.name]
          log("Re-processing cloud for entry id: #{entry.id} because of: tag: \"#{tag.noun.name}\" tag.id: #{tag.id} noun_id: #{tag.noun_id} ")
          Tag.auto_generate_tags(entry) 
          entry.reorder_tags
          fixed += 1
          break
        end                   
      end 
    end   
    log("Fixed #{fixed} entries. Total time: #{Time.now - begin_time}")
  end
end


def log(msg)
  Rails.logger.info(msg)
  puts msg
end