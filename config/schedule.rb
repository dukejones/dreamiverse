# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "log/cron.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :rake, "cd :path && RAILS_ENV=:environment /usr/local/bin/rake :task :output"

every 1.day, :at => '3:00 am' do
  rake "starlight"
end

every 3.days, :at => '4:30 am' do
  rake "image:resize"
end
