
set :application, "rails.dreamcatcher.net"

set :rails_env, 'production'
set :branch, 'production'

set :deploy_to, "/var/www/#{application}"

server "dreamcatcher.net", :web, :app, :db, :primary => true

namespace :uploads do
  desc "Symlink the uploads directory to the shared uploads directory."
  task :symlink do
    run "rm -rf #{current_release}/public/images/uploads"
    run "ln -fs /mnt/imagebank #{current_release}/public/images/uploads"
  end
end

