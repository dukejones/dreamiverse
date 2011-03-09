
set :application, "rails.dreamcatcher.net"

set :rails_env, 'production'

set :deploy_to, "/var/www/#{application}"

server "dreamcatcher.net", :web, :app, :db, :primary => true


