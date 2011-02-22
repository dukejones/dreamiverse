class Migration::UserImporter < Migration::Importer
  def initialize(user)
    super(user, User.new)
  end
  
  def migrate_all
    migrate_all_from_collection(Legacy::User.all)
  end
end