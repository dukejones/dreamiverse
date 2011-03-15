require "bundler/capistrano"

set :stages, %w(theta production)
set :default_stage, "theta"
require "capistrano/ext/multistage"


set :scm, :git
set :repository,  "git@dev.dreamcatcher.net:dreamcatcher"
set :deploy_via, :remote_cache
set :branch, "master"
set :scm_verbose, true

set :user, "www-data"
set :use_sudo, false



# after "deploy", "deploy:cleanup"
after "deploy", "barista:brew"
after "deploy", "uploads:symlink"

after "deploy:migrations", "barista:brew"
after "deploy:migrations", "uploads:symlink"

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


namespace :barista do
  task :brew do
    run("cd #{deploy_to}/current; /usr/bin/env rake barista:brew RAILS_ENV=#{rails_env}")
  end
end
