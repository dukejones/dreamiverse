class Migration::EmotionImporter < Migration::Importer
  def initialize(emotion)
    super(emotion, Emotion.new)
  end
  
  def self.migrate_all
    migrate_all_from_collection(Legacy::EmotionOption.all)
  end
end
