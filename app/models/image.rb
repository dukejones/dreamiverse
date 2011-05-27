
class Image < ActiveRecord::Base
  UPLOADS_PATH = "images/uploads"
  include ImageProfiles
  # This is the syntax we want:
  # profile 'entry_header' do |img|
  #   img.resize '720' # width => 720.
  #   vertical_offset = (img[:height] / 2) - 100 unless vertical_offset
  #   img.crop "x200+0+#{vertical_offset}" # height = 200px, cropped from the center of the image [by default].
  # end

  #
  # Assocations
  # 
  has_many :view_preferences
  has_many :whats
  belongs_to :uploaded_by, :class_name => "User"

  #
  # Callbacks 
  #
  before_destroy :delete_all_files!

  #
  # Validations
  #
  # validate format: jpg|png|etc

  #
  # Scopes
  #
  def self.enabled
    where(enabled: true)
  end
  def self.by(artist)
    where(artist: artist)
  end

  def self.sectioned(section)
    where(section ? {section: section} : {})
  end

  # TODO: currently exact match - substring would be better (esp. notes, tags, etc.)
  def self.search(params)
    # search term
    results = where(['title=? OR artist=? OR album=? OR year=? OR category=? OR genre=? OR notes=? OR tags=?', 
            params[:q], params[:q], params[:q], params[:q], params[:q], params[:q], params[:q], params[:q]])
    # filters
    results = results.where(artist: params[:artist]) if params[:artist]
    results = results.where(album: params[:album]) if params[:album]
    results = results.where(title: params[:title]) if params[:title]
    results = results.where(year: params[:year]) if params[:year]
    results = results.where(tags: params[:tags]) if params[:tags]
    # categories - replaces genre
    results = results.where(category: params[:categories].split(',')) if params[:categories]
    results
  end

  #
  # Class Methods
  #
  attr_accessor :incoming_filename

  # This is loaded via seed data.  rake db:seed
  @@default_avatar = self.where(title: 'Default Avatar').first
  def self.default_avatar; @@default_avatar; end
  
  def self.albums
    select("distinct(album)").map(&:album)
  end

  def self.artists
    select("distinct(artist)").map(&:artist)
  end
  
  #
  # Instance Methods
  #
  def write(binary_data)
    delete_all_resized_files!
    @original_magick = MiniMagick::Image.read(binary_data)
    set_metadata
    convert_to_web_format(@original_magick)
    save!
    @original_magick.write(path)
  end

  def import_from_file(filename, original_filename=nil)
    original_filename ||= filename.split('/').last
    self.incoming_filename = original_filename
    file = open(filename, 'rb')
    self.write( file.read )
    self.save
  end

  # Generates the crops and resizes necessary for the requested profile.
  def generate(descriptor, options={})
    if /\d+x\d+/.match(descriptor)
      resize(descriptor)
    else
      generate_profile(descriptor, options)
    end
  end

  # Invoked if passed a single descriptor consisting of the dimensions, eg: 64x64
  def resize(dimensions)
    return if File.exists? path(dimensions)
    img = magick_image
    img.resize dimensions
    img.write path(dimensions) # dimensions is the descriptor.
  end
  
  # Descriptor is a descriptor of the transformation.
  # Can be a role name or a resize geometry.
  def path(descriptor=nil, options={})
    Rails.public_path + url(descriptor, options)
  end

  def url(descriptor=nil, options={})
    path = UPLOADS_PATH
    path += '/originals' unless descriptor
    "/#{path}/#{filename(descriptor, options)}"
  end
  
  def filename(descriptor=nil, options={})
    fname = "#{id}"
    fname += "-#{descriptor}" if descriptor
    fname += "-#{options[:size]}" if options[:size]
    "#{fname}.#{options[:format] ? options[:format] : format}"
  end
  
  def magick_image(descriptor=nil, options={})
    MiniMagick::Image.open(path(descriptor, options))
  end
  
  def magick_info(info)
    @original_magick ||= MiniMagick::Image.new(path)
    @original_magick[info]
  end

  def delete_all_resized_files!
    Dir["#{Rails.public_path}/#{UPLOADS_PATH}/#{self.id}-*"].each do |filename|
      File.delete filename
      Rails.logger.info "Deleted previously resized file: #{filename}."
    end
  end

protected
  
  def set_metadata
    if @incoming_filename
      self.original_filename = @incoming_filename
      self.title = @incoming_filename.split('.')[0...-1].join(' ').titleize if self.title.blank?
    else
      Rails.logger.warn("New image saved with no incoming filename.")
    end
    
    self.format = magick_info(:format).downcase
    self.format = 'jpg' if self.format == 'jpeg'
    self.size = magick_info(:size)
    self.width, self.height = magick_info(:dimensions)
    self.save!
  end
  
  def convert_to_web_format(img)
    unless Mime::Type.lookup_by_extension(self.format)
      img.format 'jpg'
      self.format = 'jpg'
    end
  end

  # Side-Effect: changes @incoming_filename if it detects a URL.
  def pull_url
    if (url_matches = @incoming_filename.scan(/(^http[\-\:](::|\/\/)[^\s]+)(.*)/).first)
      slashes, url, extra = url_matches
      url.gsub!(':','/')
      url.sub!('http-','http:')
      self.source_url = url
      last_bit = url.split('/').last
      @incoming_filename = last_bit + extra
    end
    
  end
  def delete_all_files!
    if File.exists?(self.path)
      File.delete(self.path) 
      Rails.logger.info "Deleted #{self.path}."
    else
      Rails.logger.info "Could not find file: #{self.path}"
    end
    delete_all_resized_files!
  end
end

