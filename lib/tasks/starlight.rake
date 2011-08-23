task :starlight => ['starlight:snapshot', 'starlight:entropize']

namespace :starlight do
  desc "Entropize all Starlight"
  task :entropize => :environment do
    log("Entropizing all starlight")
    
    [Entry, User, What].each do |starlit_class|
      starlit_class.where("starlight > 0").each do |entity|
        begin
          entity.entropize!
        rescue
          log "invalid entity! #{entity.class} #{entity.id}"
        end
      end
    end
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
