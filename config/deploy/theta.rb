
set :application, "theta.dreamcatcher.net"
set :rails_env, 'theta'
set :whenever_environment, 'theta'

set :deploy_to, "/var/www/#{application}"

server "dev.dreamcatcher.net", :web, :app, :db, :primary => true, :memcached => true

before 'uploads:symlink', 'uploads:create_shared'
namespace :uploads do
  desc "Symlink the uploads directory to the shared uploads directory."
  task :symlink do
    run "rm -rf #{current_release}/public/images/uploads"
    run "ln -fs #{shared_path}/images/uploads #{current_release}/public/images/"
  end
  
  desc "Create the shared image uploads directory if it doesn't exist, and set the correct permissions."
  task :create_shared do
    run "mkdir -p #{shared_path}/images/uploads/originals; chmod -R 775 #{shared_path}/images/uploads"
  end
end
