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
# before "deploy:symlink", "barista:brew"
# before "deploy:symlink", "jmvc:compile"
# before "deploy:symlink", "jammit:package"
# before "deploy:restart", "compile_all"
before "deploy:symlink", "compile_all"


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

# namespace :barista do
#   task :brew do
#     run("cd #{current_release}; /usr/bin/env bundle exec rake barista:brew RAILS_ENV=#{rails_env}")
#   end
# end
# 
# 
# namespace :jammit do
#   task :package do
#     run("cd #{current_release}; /usr/bin/env bundle exec jammit")
#   end
# end

def rake(cmd, options={}, &block)
  # options.merge {:env => {'RAILS_ENV' => rails_env}}
  command = "cd #{current_release} && /usr/bin/env bundle exec rake " + cmd
  run(command, options, &block)
end

