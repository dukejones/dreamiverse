
desc "Tail the logs"
task :logs do
  on roles(:app) do
    execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
  end
end

desc "Open a console"
task :console do
  on roles(:app) do
    within current_path do
      execute "ruby -v"
      execute "bundle exec rails c #{fetch(:rails_env)}"
    end
  end
end
