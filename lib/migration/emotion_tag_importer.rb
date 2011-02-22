class Migration::EmotionTagImporter < Migration::Importer
  def initialize(emo_tag)
    super(emo_tag, Tag.new)
  end
  
  def migrate
    
    if Tag.where(noun_id: @entity_to_migrate.noun_id, noun_type: 'Emotion', 
      entry_id: @entity_to_migrate.entry_id).count >= 1
      
      break
    else
      super
    end
    
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Emotion.all)
  end
end
