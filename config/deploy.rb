require "bundler/capistrano"

set :stages, %w(theta production)
set :default_stage, "theta"
require "capistrano/ext/multistage"

set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'

set :scm, :git
set :repository,  "git@dev.dreamcatcher.net:dreamcatcher"
set :deploy_via, :remote_cache
set :branch, "master"
set :scm_verbose, true

set :user, "www-data"
set :use_sudo, false



after "deploy", "deploy:cleanup"
before "deploy:symlink", "uploads:symlink"
before "deploy:restart", "compile:the_rest"
before "deploy:restart", "compile:jmvc"


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


namespace :compile do
  task :jmvc do
    run("cd #{current_release}/public; /usr/bin/env ./js dreamcatcher/scripts/build.js")
  end
  
  task :the_rest do
    rake 'compile'
  end
end

def rake(cmd, options={}, &block)
  command = "cd #{current_release} && /usr/bin/env bundle exec rake #{cmd} RAILS_ENV=#{rails_env}"
  run(command, options, &block)
end

