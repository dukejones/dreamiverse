
desc "Tail the logs"
task :logs do
  on roles(:app) do
    execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
  end
end
