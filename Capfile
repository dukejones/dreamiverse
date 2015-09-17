# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
# require 'capistrano/passenger'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }


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

namespace :memcached do
  desc "Start memcached"
  task :start do
    on roles(:app) do #, :only => {:memcached => true}
      sudo "service memcached start"
    end
  end
  desc "Stop memcached"
  task :stop do
    on roles(:app) do #, :only => {:memcached => true}
      sudo "service memcached stop"
    end
  end
  desc "Restart memcached"
  task :restart do
    on roles(:app) do #, :only => {:memcached => true}
      # sudo "service memcached restart"
      sudo "service memcached stop"
      sudo "service memcached start"
    end
  end
  desc "Flush memcached - this assumes memcached is on port 11211"
  task :flush do
    on roles(:app) do #, :only => {:memcached => true}
      run "echo 'flush_all' | nc localhost 11211"
    end
  end
  desc "Symlink the memcached.yml file into place if it exists"
  task :symlink_configs do
    on roles(:app) do #, :only => {:memcached => true}, :except => { :no_release => true } do
      run "if [ -f #{shared_path}/config/memcached.yml ]; then ln -nfs #{shared_path}/config/memcached.yml #{latest_release}/config/memcached.yml; fi"
    end
  end
end


# namespace :bluepill do
#   desc "Stop processes that bluepill is monitoring and quit bluepill"
#   task :stop, :roles => [:app] do
#     run "#{sudo} bluepill stop"
#     sleep 1 # better to wait for pid
#     run "#{sudo} bluepill quit"
#   end

#   desc "Load bluepill configuration and start it"
#   task :start, :roles => [:app] do
#     run "#{sudo} env APP_PATH='#{current_path}' bluepill load #{current_path}/config/#{rails_env}.pill"
#   end

#   desc "Restart bluepill and reload the bluepill configuration"
#   task :restart, :roles => [:app] do
#     quit
#     start
#   end

#   desc "Prints bluepill's monitored processes' statuses"
#   task :status, :roles => [:app] do
#     run "#{sudo} bluepill status"
#   end
# end

