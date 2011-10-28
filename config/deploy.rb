set :application, "dreamcatcher"

require "bundler/capistrano"

set :stages, %w(theta production)
set :default_stage, "theta"
require "capistrano/ext/multistage"

set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'

set :scm, :git
set :repository,  "iamgit@vajrasong.com:dreamcatcher.git"
set :deploy_via, :remote_cache
set :branch, "master"
set :scm_verbose, true

set :user, "capistrano"
set :use_sudo, false

# may help with ubuntu ssh
ssh_options[:paranoid] = false
default_run_options[:pty] = true

set :keep_releases, 5
# after "deploy", "deploy:cleanup"

before "deploy:symlink", "barista:brew"
before "deploy:symlink", "uploads:symlink"
# before "deploy:symlink", "jmvc:compile"
before "deploy:symlink", "memcached:restart"


namespace :barista do
  task :brew do
    run("cd #{release_path}; bundle exec rake barista:brew RAILS_ENV=#{rails_env}")
  end
end

namespace :jmvc do
  task :compile do
    run("cd #{release_path}/public; ./js dreamcatcher/scripts/build.js")
  end
end

task :tail_log, :roles => :app do
  run "tail -f #{shared_path}/log/#{rails_env}.log"
end


# Magical Unicorn GO!
def unicorn_pid
  "#{shared_path}/pids/unicorn.pid"
end
def signal_unicorn(signal="")
  "#{try_sudo} kill -s #{signal} `cat #{unicorn_pid}`"
end

after "deploy:start", "bluepill:start"
namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    # run "cd #{current_path} && #{try_sudo} bundle exec unicorn -c #{current_path}/config/unicorn.rb -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "[ -e #{unicorn_pid} ] && echo Killing Unicorn PID: `cat #{unicorn_pid}` && #{signal_unicorn}"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run signal_unicorn("QUIT")
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run signal_unicorn("USR2")
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    graceful_stop
    # start
  end
end

namespace :memcached do 
  desc "Start memcached"
  task :start, :roles => [:app], :only => {:memcached => true} do
    sudo "service memcached start"
  end
  desc "Stop memcached"
  task :stop, :roles => [:app], :only => {:memcached => true} do
    sudo "service memcached stop"
  end
  desc "Restart memcached"
  task :restart, :roles => [:app], :only => {:memcached => true} do
    sudo "service memcached restart"
  end
  desc "Flush memcached - this assumes memcached is on port 11211"
  task :flush, :roles => [:app], :only => {:memcached => true} do
    sudo "echo 'flush_all' | nc localhost 11211"
  end
  desc "Symlink the memcached.yml file into place if it exists"
  task :symlink_configs, :roles => [:app], :only => {:memcached => true }, :except => { :no_release => true } do
    run "if [ -f #{shared_path}/config/memcached.yml ]; then ln -nfs #{shared_path}/config/memcached.yml #{latest_release}/config/memcached.yml; fi"
  end
end

namespace :bluepill do
  desc "Stop processes that bluepill is monitoring and quit bluepill"
  task :quit, :roles => [:app] do
    run "#{sudo} bluepill stop"
    run "#{sudo} bluepill quit"
  end
 
  desc "Load bluepill configuration and start it"
  task :start, :roles => [:app] do
    run "APP_PATH='#{current_path}' #{sudo} bluepill load #{current_path}/config/#{rails_env}.pill"
  end
 
  desc "Prints bluepills monitored processes statuses"
  task :status, :roles => [:app] do
    run "#{sudo} bluepill status"
  end
end

##########################################

task :install_logrotation, :roles => :app do
  logrotate = <<-LOGROTATE 
    #{shared_path}/log/*.log {
      daily
      missingok
      rotate 30
      compress
      size 5M
      delaycompress
      sharedscripts
      postrotate
        #{signal_unicorn("USR2")}
      endscript
    }
  LOGROTATE
  tmpfile = "/tmp/#{application}.logrotate"

  put(logrotate, tmpfile)
  run "#{sudo} chown root:root #{tmpfile} && #{sudo} mv -f #{tmpfile} /etc/logrotate.d/#{application}"
end

