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
# ssh_options[:paranoid] = false
# default_run_options[:pty] = true

set :keep_releases, 5
# after "deploy", "deploy:cleanup"

after "deploy", "deploy:cleanup"
before "deploy:symlink", "uploads:symlink"
before "deploy:restart", "compile:assets"
# before "deploy:restart", "compile:jmvc"
# before "deploy:symlink", "barista:brew"
before "deploy:symlink", "memcached:restart"



task :tail_log, :roles => :app do
  run "tail -f #{shared_path}/log/#{rails_env}.log"
end


namespace :compile do
  task :jmvc do
    run("cd #{current_release}/public; /usr/bin/env ./js dreamcatcher/scripts/build.js")
  end
  
  task :assets do
    rake 'compile'
  end
  
  task :haml do
    rake 'app:ping'
  end

  # task :barista do
  #   # run("cd #{release_path}; bundle exec rake barista:brew RAILS_ENV=#{rails_env}")
  #   rake 'barista:brew'
  # end
end

def rake(cmd, options={}, &block)
  command = "cd #{current_release} && /usr/bin/env bundle exec rake #{cmd} RAILS_ENV=#{rails_env}"
  run(command, options, &block)
end

# Magical Unicorn GO!
def unicorn_pid
  "#{shared_path}/pids/unicorn.pid"
end
def signal_unicorn(signal="")
  "#{sudo} kill -s #{signal} `cat #{unicorn_pid}`"
end

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    # run "cd #{current_path} && #{try_sudo} bundle exec unicorn -c #{current_path}/config/unicorn.rb -E #{rails_env} -D"
    run "#{sudo} god start dreamcatcher"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    # run "[ -e #{unicorn_pid} ] && echo Killing Unicorn PID: `cat #{unicorn_pid}` && #{signal_unicorn}"
    run "#{sudo} god stop dreamcatcher"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    # run signal_unicorn("QUIT")
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run signal_unicorn("USR2")
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run signal_unicorn("HUP")
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
    # sudo "service memcached restart"
    sudo "service memcached stop"
    sudo "service memcached start"
  end
  desc "Flush memcached - this assumes memcached is on port 11211"
  task :flush, :roles => [:app], :only => {:memcached => true} do
    run "echo 'flush_all' | nc localhost 11211"
  end
  desc "Symlink the memcached.yml file into place if it exists"
  task :symlink_configs, :roles => [:app], :only => {:memcached => true }, :except => { :no_release => true } do
    run "if [ -f #{shared_path}/config/memcached.yml ]; then ln -nfs #{shared_path}/config/memcached.yml #{latest_release}/config/memcached.yml; fi"
  end
end

namespace :bluepill do
  desc "Stop processes that bluepill is monitoring and quit bluepill"
  task :stop, :roles => [:app] do
    run "#{sudo} bluepill stop"
    sleep 1 # better to wait for pid
    run "#{sudo} bluepill quit"
  end
 
  desc "Load bluepill configuration and start it"
  task :start, :roles => [:app] do
    run "#{sudo} env APP_PATH='#{current_path}' bluepill load #{current_path}/config/#{rails_env}.pill"
  end

  desc "Restart bluepill and reload the bluepill configuration"
  task :restart, :roles => [:app] do
    quit
    start
  end

  desc "Prints bluepill's monitored processes' statuses"
  task :status, :roles => [:app] do
    run "#{sudo} bluepill status"
  end
end

##########################################

namespace :setup do
  task :install_logrotation, :roles => :app do
    logrotate = <<-BASH 
      #{shared_path}/log/*.log {
        daily
        missingok
        rotate 30
        compress
        size 5M
        delaycompress
        sharedscripts
        postrotate
          #{signal_unicorn("USR1")}
        endscript
      }
    BASH
    tmpfile = "/tmp/#{application}.logrotate"

    put(logrotate, tmpfile)
    run "#{sudo} chown root:root #{tmpfile} && #{sudo} mv -f #{tmpfile} /etc/logrotate.d/#{application}"
  end
end
