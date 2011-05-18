
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
  before_validation :parse_incoming_parameters
  
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
    # genres
    results = results.where(genre: params[:genres].split(',')) if params[:genres]
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
    begin
      parse_incoming_parameters
      delete_all_resized_files!
      file = File.open(path, 'wb')
      file.write(binary_data)
    ensure
      file._?.close
    end
    set_metadata!
  end

  def import_from_file(filename)
    self.incoming_filename = filename.split('/').last
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

  def delete_all_resized_files!
    Dir["#{Rails.public_path}/#{UPLOADS_PATH}/#{self.id}-*"].each do |filename|
      File.delete filename
      Rails.logger.info "Deleted #{filename}."
    end
  end

protected
  
  def parse_incoming_parameters
    if @incoming_filename
      # TODO: use named regexp matches
      # p "hello 2011!".match(/(?<year>\d+)/)[:year]  # => "2011"

      # Parse the URL if it's in the filename.
      if (url_matches = @incoming_filename.scan(/(^http-::[^\s]+)(.*)/).first)
        url, extra = url_matches
        url.gsub!(':','/')
        url.sub!('http-','http:')
        self.source_url = url
        last_bit = url.split('/').last
        @incoming_filename = last_bit + extra
      end

      # Remove any dates from the filename.
      if (date_range = @incoming_filename.scan(/\d{4}-\d{4}/).first)
        self.year = date_range.split('-').last
      elsif (date = @incoming_filename.scan(/\d{4}/).last)
        self.year = date
      end
      
      self.original_filename = @incoming_filename
      self.format = @incoming_filename.split('.').last.downcase if self.format.blank?
      self.title = @incoming_filename.split('.')[0...-1].join(' ').titleize if self.title.blank?
    end
  end
  
  def set_metadata!
    img = magick_image
    update_attributes!({
      width: img[:width],
      height: img[:height],
      size: img[:size]
    })
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

