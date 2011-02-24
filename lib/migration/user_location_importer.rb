class Migration::UserLocationImporter < Migration::Importer
  def initialize(location)
    super(location, Where.new)
  end

  def migrate    
    super
    user = @entity_to_migrate.user.find_or_create_corresponding_user
    user.wheres << @migrated_entity
    @migrated_entity
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::UserLocationOption.joins(:location))
  end
end