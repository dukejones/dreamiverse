class Migration::CommentImporter < Migration::Importer
  def initialize(comment)
    super(comment, Comment.new)
  end

  def self.migrate_all
    migrate_all_from_collection(Legacy::Comment.all)
  end
end
