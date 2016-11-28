
set :application, "dreamcatcher.net"

set :rails_env, 'production'
set :branch, 'master'

set :deploy_to, "/srv/#{fetch(:application)}"

server "deploy@dreamcatcher.net", roles: %w{web app db}, primary: true, memcached: false

# after "deploy:restart", "compile:haml"


# Note: We should just use the public/system directory.
# namespace :uploads do
#   desc "Symlink the uploads directory to the shared uploads directory."
#   task :symlink do
#     # Note: imagemagick is creating new images owned by root & having 644 perms
#     # chmod -R 775 #{shared_path}/imagebank
#     run "mkdir -p #{shared_path}/imagebank/originals"
#     run "rm -rf #{release_path}/public/images/uploads"
#     run "ln -fs #{shared_path}/imagebank #{current_release}/public/images/uploads"
#   end
# end


