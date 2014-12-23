
class Image < ActiveRecord::Base
  # include ImageProfiles
  include ImageFileManager

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
  has_many :users
  
  #
  # Callbacks 
  #
  # before_destroy :delete_all_files!

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
    results = results.where(category: params[:categories].split(',')) if params[:categories]
    results
  end

  #
  # Class Methods
  #
  attr_accessor :incoming_filename

  # This is loaded via seed data.  rake db:seed
  DEFAULT_AVATAR = self.where(title: 'Default Avatar').first
  def self.default_avatar
    DEFAULT_AVATAR
  end
  
  def self.albums
    select("distinct(album)").map(&:album)
  end

  def self.artists
    select("distinct(artist)").map(&:artist)
  end
  
  #
  # Instance Methods
  #

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
    # return if File.exists? path(dimensions)
    # img = magick_image
    # img.resize dimensions
    # img.write path(dimensions) # dimensions is the descriptor.
  end
  
  
  # def magick_image(descriptor=nil, options={})
  #   MiniMagick::Image.open(path(descriptor, options))
  # end
  
  protected
  
  def set_metadata
    if @incoming_filename
      self.original_filename = @incoming_filename
      self.title = @incoming_filename.split('.')[0...-1].join(' ').titleize if self.title.blank?
    else
      Rails.logger.warn("New image saved with no incoming filename.")
    end
    
    # magick_image = MiniMagick::Image.new(path)

    # self[:format] = magick_image.type.downcase
    # self.format = 'jpg' if self.format == 'jpeg'
    # self.size = magick_image.size
    # self.width, self.height = magick_image.dimensions
    self.save!
  end
  
  def convert_to_web_format(img)
    unless Mime::Type.lookup_by_extension(self.format)
      img.format 'jpg'
      self.format = 'jpg'
    end
  end

end

