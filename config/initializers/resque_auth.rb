Resque::Server.use(Rack::Auth::Basic) do |user,pass|
  pass == 'secretness'
end