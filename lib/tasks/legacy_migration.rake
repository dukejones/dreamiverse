namespace :legacy do
  namespace :data do
    desc "import all data from legacy schema"
    task :import => :environment do
      Rake::Task['legacy:data:import:images'].invoke
      Rake::Task['legacy:data:import:users'].invoke
      Rake::Task['legacy:data:import:images_second_pass'].invoke
      Rake::Task['legacy:data:import:dreams'].invoke
      Rake::Task['legacy:data:import:dream_images'].invoke
      Rake::Task['legacy:data:import:theme_settings'].invoke
      Rake::Task['legacy:data:import:comments'].invoke
      Rake::Task['legacy:data:import:emotions'].invoke
      Rake::Task['legacy:data:import:environment_series'].invoke
      Rake::Task['legacy:data:import:user_locations'].invoke
      Rake::Task['legacy:data:import:countries'].invoke
      Rake::Task['legacy:data:import:people'].invoke
    end
    namespace :import do
      task :images => :environment do
        Migration::ImageImporter.migrate_all
      end
      task :users => [:environment] do
        Migration::UserImporter.migrate_all
      end
      task :images_second_pass => [:environment] do
        Legacy::Image.valid.each do |legacy_image|
          image = legacy_image.corresponding_object
          image.uploaded_by = legacy_image.user.corresponding_object
          image.save!
        end
      end
      task :dreams => [:environment, :images, :users] do
        Migration::DreamImporter.migrate_all
      end
      task :dream_images => [:environment] do
        Legacy::DreamImage.all.each do |dream_image|
          next unless dream_image.image._?.valid?

          image = dream_image.image._?.corresponding_object
          puts "Image does not exist!  #{dream_image.image._?.title}  for dream #{dream_image.dream._?.title}" unless image

          entry = dream_image.dream._?.corresponding_object
          puts "Entry does not exist!  #{dream_image.dream._?.title}" unless entry
          

          entry.images << image
        end
      end
      task :theme_settings => [:environment] do
        debugger
        Dir['tmp/png-sheets/*'].each do |filepath|
          filename = filepath.split('/').last
          next unless Image.where(original_filename: filename).blank?
          puts "Importing bedsheet: #{filename}"
          bedsheet = Image.create(section: 'Bedsheets', album: 'auto-imported')
          bedsheet.import_from_file(filepath)
        end
        Migration::ThemeSettingImporter.migrate_all
      end
      task :comments => [:dreams, :users] do
        Migration::CommentImporter.migrate_all
      end
      task :emotions => [:environment] do
        Migration::EmotionImporter.migrate_all
      end
      task :emotion_tags => [:environment] do
        Migration::EmotionTagImporter.migrate_all
      end
      task :environment_series => [:environment] do
        Migration::EnvironmentSeriesImporter.migrate_all
      end
      task :user_locations => [:environment] do
        Migration::UserLocationImporter.migrate_all
      end
      task :countries => :environment do
        Migration::CountryImporter.migrate_all
      end
      task :people => [:environment] do
        Migration::PersonImporter.migrate_all
      end
    end
  end
end