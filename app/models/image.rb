
class Image < ActiveRecord::Base
  include ImageFileManager
  include ImageProfiles

  #
  # Associations
  # 
  has_many :view_preferences
  has_many :whats
  belongs_to :uploaded_by, :class_name => "User"
  has_many :users
  has_and_belongs_to_many :entries  

  # after_file_intake :save_metadata

  #
  # Profiles
  # 
  # NOTE: PROFILE NAMES CANNOT CONTAIN NUMBERS DUE TO THE ROUTES REGEX

  # 200x266 - CROPPED FROM MIDDLE OF IMAGE
  profile :avatar_main do |img, options|
    shave(img, 200, 266)
  end

  # Resizes to specific dimensions, shaving off any pixels that exceed the given aspect ratio.
  def shave(img, x, y)
    img.resize("#{x}x#{y}^").gravity("Center").crop("#{x}x#{y}+0+0")
  end

  profile :header do |img, options|
    vertical_offset = 
      if options[:vertical_offset]
        options[:vertical_offset]
      else
        new_height = 720*img.height/img.width # what the height will be with width 720
        (new_height / 2) - 100 # center of image
      end

    img.resize '720' # width => 720.
    img.crop "720x200+0+#{vertical_offset}" # height = 200px, cropped.
  end

  profile :stream_header do |img, options|
    img = exec_profile(img, :header, options)
    img.minify
  end

  profile :medium do |img, options|
    img.resize('1010x720>')
  end

  profile :dreamfield_header do |img, options|
    img.crop "200x+80+0"
  end

  profile :thumb do |img, options|
    size = (options[:size] || 128).to_i
    shave(img, size, size)
  end

  profile :avatar_medium do |img, options|
    img = exec_profile(img, :avatar_main, options)
    img.resize "24%"
  end

  profile :avatar do |img, options|
    if size = options[:size]
      img = exec_profile(img, :avatar) # this profile with no size
      img.resize "#{size}x#{size}"
    else
      img = exec_profile(img, :avatar_main)
      # avatar_main is 200x266, so shave bottom 66 px
      img.crop "200x200+0+20"
    end
  end

  profile :bedsheet do |img, options|
    # change to specified format - quality: 40%
    img.quality 40
    img.resize '2048<' # only if both dimensions exceed
  end

  profile :bedsheet_small do |img, options|
    img.quality 50
    img.resize 1024
  end

  profile :tag do |img, options|
    shave(img, 43, 32)
  end

  profile :facebook do |img, options|
    exec_profile(img, :thumb, size: 256)
  end

  # 170x248
  profile :bookcover do |img, options|
    shave(img, 170, 248)
  end


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
  def self.default_avatar
    @default_avatar ||= self.where(title: 'Default Avatar').first
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

  def magick_image(profile_name=nil, options={})
    # Magick::ImageList.new(self.file_path(profile_name, options))
    # MicroMagick::Image.new(self.file_path(profile_name, options))
    MiniMagick::Image.open(self.file_path(profile_name, options))
  end

  # WARNING: Edits, resizes, etc. will alter the image file directly!
  def magick_image_direct(profile_name=nil, options={})
    MiniMagick::Image.open(self.file_path(profile_name, options))
  end

  protected

  def after_file_intake
    set_metadata
  end

  def set_metadata
    image = self.magick_image_direct

    self.width = image.width
    self.height = image.height
    # resetting the format here messes with idempotency of the file migration, 
    # since this is how the old algorithm determined the file name.
    # self[:format] = image.format # format is now a reserved method in ActiveRecord
    self.size = File.size(self.file_path)
  end
  
  def convert_to_web_format(img)
    unless Mime::Type.lookup_by_extension(self.format)
      img.format 'jpg'
      self.format = 'jpg'
    end
  end

end

