class Migration::PersonImporter < Migration::Importer
  def initialize(person)
    super(person, Who.new)
  end
  
  def migrate
    super.save!
    
    entry = @entity_to_migrate.dream.find_or_create_corresponding_entry
    
    Tag.create!(noun: @migrated_entity, entry: entry)

    @migrated_entity
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Person.all)
  end
end
