class Migration::DreamImporter < Migration::Importer
  def initialize(dream)
    super(dream, Entry.new)
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Dream.all)
  end
end