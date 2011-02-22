class Migration::CountryImporter < Migration::Importer
  def initialize(country)
    super(country, Country.new)
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Country.all)
  end
end
