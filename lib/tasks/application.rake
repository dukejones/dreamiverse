
namespace :app do
  namespace :starlight do
    desc "Entropize all Starlight"
    task :entropize => :environment do
      begin_time = Time.now
      log("---Applying Entropy to All Starlight---")
      all_entities = Starlight.all_entities
      log("#{all_entities.size} distinct entities.")
      starlights = all_entities.map {|entity| Starlight.for(entity) }
      log("Starlight retrieved for every starlit entity.")
      starlights.each do |starlight|
        starlight.entropize!
        log("#{starlight.entity_type} #{starlight.entity_id} : #{starlight.value} => #{starlight.reload.value}")
      end
      log("Total time: #{Time.now - begin_time}")
    end
  end
end

def log(msg)
  Rails.logger.info(msg)
  puts msg
end