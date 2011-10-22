
set :application, "dreamcatcher"

set :rails_env, 'production'
set :branch, 'production-rackspace'

set :deploy_to, "/var/www/#{application}"

# server "dreamcatcher.net", :web, :app, :db, :primary => true, :memcached => true
server "50.57.155.246", :web, :app, :db, :primary => true, :memcached => true


namespace :uploads do
  desc "Symlink the uploads directory to the shared uploads directory."
  task :symlink do
    run "mkdir -p #{shared_path}/imagebank/originals; chmod -R 775 #{shared_path}/imagebank" + 
    " && rm -rf #{release_path}/public/images/uploads" + 
    " && ln -fs #{shared_path}/imagebank #{current_release}/public/images/uploads"
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

