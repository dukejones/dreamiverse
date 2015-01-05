
module ImageProfiles
  extend ActiveSupport::Concern

  included do
    cattr_accessor :profiles

    def self.profile(profile_name, &block)
      self.profiles ||= {}
      self.profiles[profile_name.to_sym] = block
    end
  end

  def magick_image(profile_name=nil, options={})
    Magick::ImageList.new(self.file_path(profile_name, options))
  end

  def generate_profile(profile, options={})
    raise "Profile #{profile} does not exist." unless self.profiles.keys.include?(profile.to_sym) # && self.respond_to?(profile.to_sym)
    raise "Ridiculous resize requested" if options[:size].to_i > 15000
    Rails.logger.info("Generating Profile: #{profile} #{options.inspect}")

    transformed_magick_image = self.profiles[profile.to_sym].call(self.magick_image, options)
    save_profile(transformed_magick_image, profile, options)
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
    # return if File.exists? path(dimensions)
    # img = magick_image
    # img.resize dimensions
    # img.write path(dimensions) # dimensions is the descriptor.
  end

  # For every profile, we must define a method with the same name which generates the image for that profile.
  # def profiles
  #   [
  #     :medium, 
  #     :header, :stream_header, :dreamfield_header, 
  #     :avatar_main, :avatar_medium, :avatar, 
  #     :thumb,
  #     :bedsheet, :bedsheet_small,
  #     :tag, :facebook, :bookcover
  #   ]
  # end

  def pre_generate(profile, options={})
    # options[:format] = "jpg" unless Mime::Type.lookup_by_extension(options[:format] || self.format)
    generate_profile(profile, options) unless profile_generated?(profile, options)
  end
  
  def profile_generated?(profile, options={})
    raise "Profile #{profile} does not exist." unless profiles.include?(profile)

    File.exists?(path(profile, options))
  end
  
  def profile_magick_image(profile, options={})
    generate_profile(profile, options) unless profile_generated?(profile, options)
    magick_image(profile, options)
  end


  def convert(img, new_format=nil, quality=nil)
    img.quality quality if quality
    
    img.format new_format.to_s if new_format && self.format != new_format.to_s
  end

  ########## PROFILES #############
  
  def medium(options={})
    img = magick_image
    img.resize '720x720'
    
    img.write(path('medium'))
  end
  
  # def header(options={})
  #   vertical_offset = options[:vertical_offset]

  #   img = magick_image
  #   # self.magick.combine_options do |i|
  #   img.resize '720' # width => 720.
  #   vertical_offset = (img[:height] / 2) - 100 unless vertical_offset
  #   img.crop "x200+0+#{vertical_offset}" # height = 200px, cropped from the center of the image [by default].

  #   img.write(path('header'))
  # end

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
    size = (options[:size] || 128).to_i
    img = magick_image
    
    convert(img, options[:format])
    shave(img, size, size)
    # img.repage
    img.write(path('thumb', options))
  end
  
  
  def avatar_medium(options)
    img = profile_magick_image(:avatar_main)
    img.resize "24%"
    img.write(path(:avatar_medium))
  end
  
  # Make sure you do not ask for an avatar > 200x200
  def avatar(options)
    if size = options[:size]
      img = profile_magick_image(:avatar) # this profile with no size
      img.resize "#{size}x#{size}"
    else
      img = profile_magick_image(:avatar_main)
      # avatar_main is 200x266, so shave bottom 66 px
      img.crop "200x200+0+20"
    end
    img.write(path(:avatar, options))
  end

  def bedsheet(options)
    img = magick_image
    # change to specified format - quality: 40%
    convert(img, options[:format], 40)
    img.resize '2048<' # only if both dimensions exceed
    img.write(path(:bedsheet, options))
  end
  
  def bedsheet_small(options)
    img = magick_image
    convert(img, options[:format], 50)
    img.resize 1024
    img.write(path(:bedsheet_small, options))
  end

  def tag(options={})
    img = magick_image
    img.shave(43, 32)
    img.write(path(:tag))
  end
  
  def facebook(options={})
    img = profile_magick_image(:thumb, :size => 256)
    img.write(path(:facebook))
  end
  
  # 170x248
  def bookcover(options={})
    img = magick_image

    shave(img, 170, 248)
    
    img.write(path(:bookcover))
  end
end
