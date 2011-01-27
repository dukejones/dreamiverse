
namespace :app do
  namespace :starlight do
    desc "Entropize all Starlight"
    task :entropize => :environment do
      Starlight.entropize!
    end
  end
end
