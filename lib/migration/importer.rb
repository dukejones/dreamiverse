class Migration::Importer
  def initialize(_entity_to_migrate, _migrated_entity)
    @entity_to_migrate = _entity_to_migrate
    @migrated_entity = _migrated_entity
  end
  
  def migrate
    puts "Migrating: #{@entity_to_migrate.class} #{@entity_to_migrate.title || @entity_to_migrate.inspect.slice(0..100)}"

    # if @entity_to_migrate.respond_to?(:corresponding_object)
    #   if obj = @entity_to_migrate.corresponding_object
    #     puts "Object already imported: #{obj.class} #{obj.id}"
    #     return obj
    #   end
    # end
    
    @migrated_entity.attributes.symbolize_keys.keys.each do |attr|
      if @entity_to_migrate.respond_to?(attr)
        @migrated_entity.send("#{attr}=", @entity_to_migrate.send(attr))
      end
    end

    debugger unless @migrated_entity.valid?
    
    @migrated_entity
  end
  
  def self.migrate_all(source_class, entity_name=nil)
    migrate_all_from_collection(source_class.send(:all), entity_name)
  end
  
  def self.migrate_all_from_collection(collection, entity_name=nil)
    entity_name ||= collection.first.class.to_s.pluralize
    puts '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    puts "Migrating all: #{entity_name}"

    # if collection.first.respond_to?(:corresponding_object)
    #   collection.reject! {|obj| obj.corresponding_object }
    # end
    
    collection.each do |entity|
      result = self.new(entity).migrate
      result.save!
    end
  end
end
