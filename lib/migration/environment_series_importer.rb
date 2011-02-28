class Migration::EnvironmentSeriesImporter < Migration::Importer
  def initialize(env)
    super(env, Tag.new)
  end
  
  def migrate
    if tag = Tag.where(noun_id: @entity_to_migrate.noun_id, noun_type: 'What', 
      entry_id: @entity_to_migrate.entry_id).first
      
      puts "duplicate tag: #{tag.inspect}"
      tag
    else
      super
    end
  end
  
  def self.migrate_all
    # migrate_all_from_collection(Legacy::GlobalEnvironment.all)
    # migrate_all_from_collection(Legacy::GlobalSeries.all)
    migrate_all_from_collection(Legacy::UserEnvironment.all)
  end
end
