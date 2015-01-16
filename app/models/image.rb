
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

  # profile 'entry_header' do |img, options|
  #   img.resize '720' # width => 720.
  #   vertical_offset = (img[:height] / 2) - 100 unless vertical_offset
  #   img.crop "x200+0+#{vertical_offset}" # height = 200px, cropped from the center of the image [by default].
  # end


  # 200x266 - CROPPED FROM MIDDLE OF IMAGE
  profile :avatar_main do |img, options|
    img.resize_to_fill(200, 266)
  end

  profile :header do |img, options|
    y = options[:vertical_offset]
    img.resize! 720
    y = (img.rows / 2 - 150) unless y

  end

  def header(options={})
    vertical_offset = options[:vertical_offset]

    img = magick_image
    # self.magick.combine_options do |i|
    img.resize '720' # width => 720.
    vertical_offset = (img[:height] / 2) - 100 unless vertical_offset
    img.crop "x200+0+#{vertical_offset}" # height = 200px, cropped from the center of the image [by default].

    img.write(path('header'))
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

  protected

  def after_file_intake
    set_metadata
  end

  def set_metadata
    image = self.magick_image

    self.width = image.columns
    self.height = image.rows
    self[:format] = image.format # format is now a reserved method in ActiveRecord
    self.size = File.size(self.file_path)
  end
  
  def convert_to_web_format(img)
    unless Mime::Type.lookup_by_extension(self.format)
      img.format 'jpg'
      self.format = 'jpg'
    end
  end

end

