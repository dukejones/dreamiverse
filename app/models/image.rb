
module ImageProfiles
  # Options are always optional; defaults will be provided.
  # Size determines the size to generate. For some profiles, size will be nil because it is always the same size.
  # We should always generate the nil size profile, then resize to the specified size.

  module ClassMethods
    # def profile(name)
    #   define_method("generate_#{name}") do
    #     img = magick_image
    #     yield img
    #   end
    # end
  end
  def self.included(base)
    base.extend(ClassMethods)
  end

  # For every profile, we must define a method with the same name which generates the image for that profile.
  def profiles
    [:medium, :header, :stream_header, :dreamfield_header, :thumb, :avatar_main, :avatar_medium, :avatar]
  end

  def generate_profile(profile, size=nil, opts={})
    raise "Profile #{profile} does not exist." unless profiles.include?(profile.to_sym) && self.respond_to?(profile.to_sym)
    opts.merge!(:size => size) if size
    self.send(profile.to_sym, opts)
  end

  def profile?(profile, size=nil)
    raise "Profile #{profile} does not exist." unless profiles.include?(profile)

    File.exists?(path(profile, size))
  end
  
  def profile_magick_image(profile, size=nil, opts={})
    generate_profile(profile, size, opts) unless profile?(profile, size)
    magick_image(profile, size)
  end
  
  def medium(options={})
    img = magick_image
    img.resize '720x720'
    
    img.write(path('medium'))
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

  def stream_header(options={})
    img = profile_magick_image(:header)
    img.resize '50%'
    
    img.write(path('stream_header'))
  end
  
  def dreamfield_header(options={})
    img = profile_magick_image(:stream_header)
    # stream_header = 360x100.  Resize width -> 200.  x-offset: +80px
    img.crop "200x+80+0"
    img.write(path('dreamfield_header'))
  end
  
  def thumb(options)
    # img.thumbnail # => Faster but no pixel averaging.
    size = options[:size] || 128
    img = magick_image
    # img.combine_options do |i|
    img.resize (width > height) ? "x#{size}" : size
    
    offset = if (width > height)
      pix = (img[:width] - size.to_i) / 2
      "+#{pix}+0" 
    else
      pix = (img[:height] - size.to_i) / 2
      "+0+#{pix}"
    end
    img.crop "#{size}x#{size}#{offset}"
    # img.repage
    img.write(path('thumb', size))
  end
  
  def avatar_main(options)
    img = magick_image
    img.resize "x266"
    # crop center 200
    offset = (img[:width] - 200) / 2
    img.crop "200x+#{offset}+0"
    
    img.write(path(:avatar_main))
  end
  
  def avatar_medium(options)
    img = profile_magick_image(:avatar_main)
    img.resize "24%"
    
    img.write(path(:avatar_medium))
  end
  
  # Make sure you do not ask for an avatar > 128x128 !
  def avatar(options)
    if size = options[:size]
      img = profile_magick_image(:avatar) # this profile with no size
      img.resize "#{size}x#{size}"
    else
      img = profile_magick_image(:avatar_main)
      # avatar_main is 200x266, so shave top 66 px
      img.crop "200x200+0+66"
      img.resize "128x128"
    end
    img.write(path(:avatar, size))
  end
end

class Image < ActiveRecord::Base
  UPLOADS_PATH = "images/uploads"
  include ImageProfiles

  # This is the syntax we want:
  # profile 'entry_header' do |img|
  #   img.resize '720' # width => 720.
  #   vertical_offset = (img[:height] / 2) - 100 unless vertical_offset
  #   img.crop "x200+0+#{vertical_offset}" # height = 200px, cropped from the center of the image [by default].
  #   img
  # end

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
  scope :enabled, where(enabled: true)
  scope :by, -> artist { where(artist: artist) }

  # TIDY: where({}) causes unnecessary clone, possible performance hit?
  scope :sectioned, -> section { where(section ? {section: section} : {}) }

  # TODO: currently exact match - substring would be better (esp. notes, tags, etc.)
  scope :search, -> params {
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
  attr_accessor :incoming_filename

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
    file = File.open(path, 'wb')
    file.write(binary_data)
    set_metadata!
  rescue => e
    e
  ensure
    file._?.close
  end

  # Generates the crops and resizes necessary for the requested profile.
  def generate(descriptor, size=nil, options={})
    if size.nil? && descriptor =~ /\d+x\d+/
      resize(descriptor)
    else
      generate_profile(descriptor, size, options)
    end
  end

  # Invoked if passed a single descriptor consisting of the dimensions, eg: 64x64
  def resize(dimensions)
    return if resized? dimensions
    img = magick_image
    img.resize dimensions
    img.write path(dimensions) # dimensions is the descriptor.
  end
  
  def resized?(size)
    File.exists? path(size)
  end
  
  # Descriptor is a descriptor of the transformation.
  # Can be a role name or a resize geometry.
  def path(descriptor=nil, size=nil)
    Rails.public_path + url(descriptor, size)
  end

  def url(descriptor=nil, size=nil)
    path = UPLOADS_PATH
    path += '/originals' unless descriptor
    "/#{path}/#{filename(descriptor, size)}"
  end
  
  def filename(descriptor=nil, size=nil)
    fname = "#{id}"
    fname += "-#{descriptor}" if descriptor
    fname += "-#{size}" if size
    "#{fname}.#{format}"
  end
  
  def magick_image(descriptor=nil, size=nil)
    MiniMagick::Image.open(path(descriptor, size))
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
      self.format = @incoming_filename.split('.').last unless format
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
    File.delete self.path
    Rails.logger.info "Deleted #{self.path}."
    delete_all_resized_files!
  end

  def delete_all_resized_files!
    Dir["#{Rails.public_path}/#{UPLOADS_PATH}/#{self.id}-*"].each do |filename|
      File.delete filename
      Rails.logger.info "Deleted #{filename}."
    end
  end
end

