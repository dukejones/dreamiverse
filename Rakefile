# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
class Rails::Application
  include Rake::DSL if defined?(Rake::DSL)
end

@rake_logger = Logger.new(Rails.root.join('log', 'rake.log'), 10, 30*1024*1024)
@rake_logger.formatter = DreamLogFormatter.new

def log(msg, level=:info)
  @rake_logger.send(level, msg)
  puts msg
end

Dreamcatcher::Application.load_tasks

