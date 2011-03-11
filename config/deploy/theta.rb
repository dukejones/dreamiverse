
set :application, "theta.dreamcatcher.net"
set :rails_env, 'theta'

set :deploy_to, "/var/www/#{application}"

server "dev.dreamcatcher.net", :web, :app, :db, :primary => true

before 'uploads:symlink', 'uploads:create_shared'
namespace :uploads do
  desc "Symlink the uploads directory to the shared uploads directory."
  task :symlink do
    # these run's don't seem to be working well for us, need fixing
    # run "rm -rf #{current_path}/public/images/uploads"
    # run "ln -fs #{shared_path}/images/uploads #{current_path}/public/images/"
  end
  
  desc "Create the shared image uploads directory if it doesn't exist, and set the correct permissions."
  task :create_shared do
    run "mkdir -p #{shared_path}/images/uploads/originals; chmod -R 777 #{shared_path}/images/uploads"
  end
end
