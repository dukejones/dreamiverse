require 'bundler/capistrano'

set :stages, %w(theta production)
set :default_stage, 'theta'
require 'capistrano/ext/multistage'

# set :application, "theta.dreamcatcher.net"

set :scm, :git
set :repository,  "git@dev.dreamcatcher.net:dreamcatcher"
set :deploy_via, :remote_cache
set :branch, 'master'
set :scm_verbose, true

set :user, "www-data"
set :use_sudo, false

#role :web, "dev.dreamcatcher.net"                          # Your HTTP server, Apache/etc
#role :app, "dev.dreamcatcher.net"                          # This may be the same as your `Web` server
#role :db,  "dev.dreamcatcher.net", :primary => true # This is where Rails migrations will run
server "dev.dreamcatcher.net", :web, :app, :db, :primary => true

set :deploy_to, "/var/www/#{application}"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end
