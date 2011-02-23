class Migration::DreamImporter < Migration::Importer
  def initialize(dream)
    super(dream, Entry.new)
  end
  
  def migrate
    @migrated_entity.whats = @entity_to_migrate.whats
    super
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Dream.all)
  end
end
