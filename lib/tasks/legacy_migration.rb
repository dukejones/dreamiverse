namespace :legacy do
  namespace :data do
    desc "import all data from legacy schema"
    task :import => :environment do
      Rake::Task['legacy:data:import:users'].invoke
      
    end
    namespace :import do
      task :users => [] do
        
      end
    end
  end
end