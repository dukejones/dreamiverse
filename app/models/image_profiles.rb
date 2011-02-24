
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

  def generate_profile(profile, options={})
    raise "Profile #{profile} does not exist." unless profiles.include?(profile.to_sym) && self.respond_to?(profile.to_sym)

    self.send(profile.to_sym, options)
  end

  def profile?(profile, options={})
    raise "Profile #{profile} does not exist." unless profiles.include?(profile)

    File.exists?(path(profile, options))
  end
  
  def profile_magick_image(profile, size=nil, opts={})
    generate_profile(profile, size, opts) unless profile?(profile, :size => size)
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
    img.write(path('thumb', options))
  end
  
  def avatar_main(options)
    img = magick_image

    if width > height
      img.resize "x266"
      offset = (img[:width] - 200) / 2   # crop the center 200px
      img.crop "200x+#{offset}+0"
    else
      img.resize "200"
      offset = (img[:height] - 266) / 2
      img.crop "x266+0+#{offset}"  # crop to the center 266px
    end
    
    img.write(path(:avatar_main))
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
end
