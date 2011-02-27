class Migration::PersonImporter < Migration::Importer
  def initialize(person)
    super(person, Who.new)
  end
  
  def migrate
    super
    
    entry = @entity_to_migrate.dream.corresponding_object
    Tag.create!(noun: @migrated_entity, entry: entry)
    
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Person.all)
  end
end
