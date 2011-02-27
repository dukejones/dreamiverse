# class Migration::LocationImporter < Migration::Importer
#   def initialize(location)
#     super(location, Where.new)
#   end
#   
#   def self.migrate_all
#     migrate_all_from_collection(Legacy::UserLocationOption.all)
#   end
# end
