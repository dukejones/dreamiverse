class Migration::LinkImporter < Migration::Importer
  def initialize(link)
    super(link, Link.new)
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::DreamLink.all)
  end
end
