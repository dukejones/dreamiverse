namespace :legacy do
  namespace :data do
    desc "import all data from legacy schema"
    task :import => :environment do
      Rake::Task['legacy:data:import:images'].invoke
      Rake::Task['legacy:data:import:users'].invoke
      Rake::Task['legacy:data:import:images_second_pass'].invoke
      Rake::Task['legacy:data:import:dreams'].invoke
      Rake::Task['legacy:data:import:comments'].invoke
      Rake::Task['legacy:data:import:emotions'].invoke
      Rake::Task['legacy:data:import:environment_series'].invoke
      Rake::Task['legacy:data:import:user_locations'].invoke
      Rake::Task['legacy:data:import:countries'].invoke
    end
    namespace :import do
      task :images do
        Migration::ImageImporter.migrate_all
      end
      task :users => [:images] do
        Migration::UserImporter.migrate_all
      end
      task :images_second_pass => [:users, :images] do
        # set the uploaded by to prevent user infinite recursion.
      end
      task :dreams => [:users, :images] do
        Migration::DreamImporter.migrate_all
      end
      task :comments => [:dreams, :users] do
        Migration::CommentImporter.migrate_all
      end
      task :emotions => [:dreams] do
        Migration::EmotionImporter.migrate_all
      end
      task :emotion_tags => [:dreams, :emotions] do
        Migration::EmotionTagImporter.migrate_all
      end
      task :environment_series => [:dreams] do
        Migration::EnvironmentSeriesImporter.migrate_all
      end
      task :user_locations => [:users] do
        Migration::UserLocationimporter.migrate_all
      end
      task :countries do
        Migration::CountryImporter.migrate_all
      end
      task :people => [:users, :dreams] do
        Migration::PersonImporter.migrate_all
      end
    end
  end
end