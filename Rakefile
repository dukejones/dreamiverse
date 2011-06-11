# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

def log(msg)
  @rake_logger ||= ActiveSupport::BufferedLogger.new Rails.root.join('log', 'rake.log')
  @rake_logger.info "(#{Time.zone.now.to_s(:short)}) #{msg}"
  # Rails.logger.info("(#{Time.zone.now.to_s(:short)}) #{msg}")
  puts msg
end

Dreamcatcher::Application.load_tasks
