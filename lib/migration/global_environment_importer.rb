class Migration::GlobalEnvironmentImporter < Migration::Importer
  def initialize(env)
    super(env, Tag.new)
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Country.all)
  end
end
