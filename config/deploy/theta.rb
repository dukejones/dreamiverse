
set :application, "theta.dreamcatcher.net"
set :rails_env, 'theta'

set :deploy_to, "/var/www/#{application}"

server "dev.dreamcatcher.net", :web, :app, :db, :primary => true

