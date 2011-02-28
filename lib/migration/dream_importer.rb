class Migration::DreamImporter < Migration::Importer
  require 'mocha'
  
  def initialize(dream)
    entry = Entry.new
    entry.stubs(:process_all_tags).returns(true)
    super(dream, entry)
  end
  
  def migrate
    # @migrated_entity.whats = @entity_to_migrate.whats
    super
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Dream.all)
  end
end
