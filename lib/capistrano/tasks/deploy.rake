
namespace :deploy do
  after :deploy, "puma:restart"
  after :rollback, "puma:restart"
end


=begin
# Unicorn
namespace :deploy do

  desc "Makes sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} Unicorn server."
    task command do
      on roles(:app) do
        # execute "/etc/init.d/#{fetch(:application)}_unicorn #{command}"
        execute "/etc/init.d/dreamcatcher_unicorn #{command}"
      end
    end
  end

  # before :deploy, "deploy:check_revision"
  after :deploy, "deploy:restart"
  after :rollback, "deploy:restart"
end
=end

=begin
# Magical Unicorn GO!
def unicorn_pid
  "#{shared_path}/pids/unicorn.pid"
end
def signal_unicorn(signal="")
  "#{sudo} kill -s #{signal} `cat #{unicorn_pid}`"
end
namespace :deploy do
  task :start do
    on roles(:app) do #, :except => { :no_release => true }
      # run "cd #{current_path} && #{try_sudo} bundle exec unicorn -c #{current_path}/config/unicorn.rb -E #{rails_env} -D"
      run "#{sudo} god start dreamcatcher"
    end
  end
  task :stop do
    on roles(:app) do #, :except => { :no_release => true }
      # run "[ -e #{unicorn_pid} ] && echo Killing Unicorn PID: `cat #{unicorn_pid}` && #{signal_unicorn}"
      run "#{sudo} god stop dreamcatcher"
    end
  end
  # task :graceful_stop, :roles => :app, :except => { :no_release => true } do
  #   # run signal_unicorn("QUIT")
  # end
  task :reload do
    on roles(:app) do #, :except => { :no_release => true }
      run signal_unicorn("USR2")
    end
  end
  task :restart do
    on roles(:app) do #, :except => { :no_release => true }
      run signal_unicorn("HUP")
    end
  end
end
=end
