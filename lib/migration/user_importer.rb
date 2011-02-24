class Migration::UserImporter < Migration::Importer
  def initialize(user)
    super(user, User.new)
  end
  
  def migrate
    theme_setting = @entity_to_migrate.default_theme_setting
    if theme_setting
      # import the image : bedsheetPath
      
      @migrated_entity.view_preference_attributes = {
        theme: theme_setting.theme,
        bedsheet_attachment: theme_setting.scroll
      }
    end
    super
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::User.all)
  end
end