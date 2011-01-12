class Image < ActiveRecord::Base
  #
  # Callbacks 
  #
  before_validation :parse_incoming_parameters

  #
  # Validations
  #
  # validate format: jpg|png|etc

  #
  # Scopes
  #
  scope :by, lambda { |artist| where(artist: artist) }

  # TIDY: where({}) causes unnecessary clone, possible performance hit?
  scope :sectioned, lambda { |section| where(section ? {section: section} : {}) }

  # TODO: currently exact match - substring would be better (esp. notes, tags, etc.)
  # TIDY: can I do this more elegantly? (without the intermediate variable 'results')
  scope :search, lambda { |params|
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
  }

  #
  # Class Methods
  #
  def self.albums
    select("distinct(album)").map(&:album)
  end

  def self.artists
    select("distinct(artist)").map(&:artist)
  end
  
  #
  # Instance Methods
  #
  def incoming_filename=(fname)
    @incoming_filename = fname
  end
  
  def write(binary_data)
    parse_incoming_parameters
    
    file = File.open(path, 'wb')
    file.write(binary_data)
  rescue => e
    e
  ensure
    file && file.close
  end

  def resize(size)
    return if resized? size
    
    i = magick
    i.resize size
    i.write path(size)
  end
  
  def resized?(size)
    File.exists? path(size)
  end
  
  def path(size=nil)
    Rails.public_path + url(size)
  end

  def url(size=nil)
    path = "/images/uploads"
    path += '/originals' unless size
    "#{path}/#{filename(size)}"
  end
  
  def filename(size=nil)
    fname = "#{id}-#{title.parameterize}"
    fname += "-#{size}" if size
    "#{fname}.#{format}"
  end
  
  def magick(size=nil)
    MiniMagick::Image.open(path(size))
  end

protected
  def parse_incoming_parameters
    if @incoming_filename
      self.format = @incoming_filename.split('.').last unless format
      # Should all formats be jpg?
      # @image.format = "jpg"
      
      self.title = @incoming_filename.split('.')[0...-1].join(' ').titleize unless title
    end
  end
end
