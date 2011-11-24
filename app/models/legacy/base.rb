class Legacy::Base < ActiveRecord::Base
  self.abstract_class = true
  # establish_connection "dc-alpha"
  @@import_logger = Logger.new( File.open("#{Rails.root}/log/import.log", 'a') )
  def log(msg)
    @@import_logger.warn(msg)
    puts msg
  end
end