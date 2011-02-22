class Migration::EmotionTagImporter < Migration::Importer
  def initialize(emo_tag)
    super(emo_tag, Tag.new)
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::Emotion.all)
  end
end
