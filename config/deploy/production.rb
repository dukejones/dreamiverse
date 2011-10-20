
set :application, "dreamcatcher"

set :rails_env, 'production'
set :branch, 'production-rackspace'

set :deploy_to, "/var/www/#{application}"

# server "dreamcatcher.net", :web, :app, :db, :primary => true, :memcached => true
server "50.57.155.246", :web, :app, :db, :primary => true, :memcached => true


before 'uploads:symlink', 'uploads:create_shared'
namespace :uploads do
  desc "Symlink the uploads directory to the shared uploads directory."
  task :symlink do
    run "rm -rf #{current_release}/public/images/uploads"
    run "ln -fs #{shared_path}/images/uploads #{current_release}/public/images/"
  end
  
  desc "Create the shared image uploads directory if it doesn't exist, and set the correct permissions."
  task :create_shared do
    run "mkdir -p #{shared_path}/images/uploads/originals; chmod -R 777 #{shared_path}/images/uploads"
  end
end

# When it was mounted off of S3.
# namespace :uploads do
#   desc "Symlink the uploads directory to the shared uploads directory."
#   task :symlink do
#     run "rm -rf #{current_release}/public/images/uploads"
#     run "ln -fs /mnt/imagebank #{current_release}/public/images/uploads"
#   end
# end

