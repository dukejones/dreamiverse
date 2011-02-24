class Migration::ImageImporter < Migration::Importer
  def initialize(image)
    super(image, Image.new)
  end
  
  LegacyImageDir = "#{Rails.root}/tmp/images/user"
  def migrate
    image = super
    legacy_image = @entity_to_migrate
    image.incoming_filename = legacy_image.filename
    image.format = nil
    image.save!
    
    image.import_from_file("#{LegacyImageDir}/#{legacy_image.path}")

    image
  end

  def self.migrate_all
    migrate_all_from_collection(Legacy::Image.valid)
  end
end
