
set :application, "dreamcatcher"

set :rails_env, 'production'
set :branch, 'production'

set :deploy_to, "/var/www/#{application}"

server "dreamcatcher.net", :web, :app, :db, :primary => true, :memcached => true

after "deploy:restart", "compile:haml"

# Note: We should just use the public/system directory.
namespace :uploads do
  desc "Symlink the uploads directory to the shared uploads directory."
  task :symlink do
    # Note: imagemagick is creating new images owned by root & having 644 perms
    # chmod -R 775 #{shared_path}/imagebank
    run "mkdir -p #{shared_path}/imagebank/originals" + 
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

