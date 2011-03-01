class Migration::ThemeSettingImporter < Migration::Importer
  def initialize(theme)
    super(theme, ViewPreference.new)
  end
  
  def migrate
    super
    @theme_setting = @entity_to_migrate
    @view_preference = @migrated_entity
    
    viewables = (@theme_setting.users + @theme_setting.dreams).map do |legacy_viewable|
      new_viewable = legacy_viewable.corresponding_object
      puts "Missing element!!  #{legacy_viewable.inspect}" if new_viewable.nil?
      new_viewable
    end.compact
    
    viewables.each do |viewable|
      viewable.view_preference = @view_preference.clone!
    end

  end

  def self.migrate_all
    collection = Legacy::ThemeSetting.all
    entity_name ||= collection.first.class.to_s.pluralize
    puts '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    puts "Migrating all: #{entity_name}"

    collection.each do |entity|
      result = self.new(entity).migrate
    end

  end
end
