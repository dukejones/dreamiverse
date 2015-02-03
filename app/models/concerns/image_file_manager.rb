require 'open-uri'

module ImageFileManager
  extend ActiveSupport::Concern

  UPLOAD_DIR = "imagebank"
  CACHE_DIR = "imagebank-cache"

  # give me a filename (or url)
  # i copy it into the proper place
  # and return the path for storage in the db
  def intake_file(src_file)
    raise ImageException.new("Not a file") if !File.file?(src_file) 
    raise ImageException.new("Not an image file") if Magick::Image::read(src_file).blank?

    relative_upload_path = generate_relative_upload_path(src_file)
    dest_file = File.join Rails.public_path, UPLOAD_DIR, relative_upload_path
    FileUtils.mkdir_p File.dirname(dest_file)

    open(dest_file, 'wb') do |dest|
      open(src_file, 'rb') do |src|
        dest.write(src.read)
      end
    end

    self.image_path = relative_upload_path
    self.after_file_intake

    return relative_upload_path
  end

  def intake_file!(src_file)
    self.intake_file(src_file)

    self.save!
    
  end
  # generate a path for a file based on its created_at,
  # postfixing numbers to avoid name collisions if necessary.
  def generate_relative_upload_path(src_file)
    path = File.join created_at.year.to_s, created_at.month.to_s, File.basename(src_file)

    postfix = 0
    while File.file?(File.join Rails.public_path, UPLOAD_DIR, path) do # if filename collision
      postfix += 1
      # myfile-001.png
      path = File.join File.dirname(path), 
                    File.basename(src_file, ".*")+("-%03d" % postfix)+File.extname(src_file)
    end
    return path
  end

  # Gives the full file path to a particular profile of an image
  # Descriptor is the name of the profile.
  # If given no arguments, output should be the same as the `image_path` column.
  # x Can also be a resize geometry.
  def file_path(descriptor=nil, options={})
    File.join( Rails.public_path, url(descriptor, options) )
  end

  # Returns the relative path from the public directory.
  def url(descriptor=nil, options={})
    base_path = descriptor ? CACHE_DIR : UPLOAD_DIR # pointing to original image or resized?

    '/' + File.join( base_path, created_at.year.to_s, created_at.month.to_s, filename(descriptor, options) )
  end
  
  def filename(descriptor=nil, options={})
    filename = File.basename( self.image_path, ".*" )
    filename += "-#{descriptor}" if descriptor
    filename += "-#{options[:size]}" if options[:size]
    # "#{fname}.#{options[:format] ? options[:format] : format}"
    filename += File.extname( self.image_path )
    filename
  end


  def save_profile(rmagick_image, profile_name, options={})
    profile_file = self.file_path(profile_name, options)
    FileUtils.mkdir_p File.dirname(profile_file)
    rmagick_image.write profile_file
  end

  # def write(binary_data)
  #   delete_all_resized_files!
  #   @original_magick = MiniMagick::Image.read(binary_data)
  #   set_metadata
  #   convert_to_web_format(@original_magick)
  #   save!
  #   @original_magick.write(path)
  # end

  # TODO: rename to clear_cached_files!
  def delete_all_resized_files!
    # Dir["#{Rails.public_path}/#{UPLOAD_DIR}/#{self.id}-*"].each do |filename|
    #   File.delete filename
    #   Rails.logger.info "Deleted previously resized file: #{filename}."
    # end
  end

  ### brought in from previous version of Image
  def legacy_filename(descriptor=nil, options={})
    fname = "#{id}"
    fname += "-#{descriptor}" if descriptor
    fname += "-#{options[:size]}" if options[:size]
    "#{fname}.#{options[:format] ? options[:format] : format}"
  end

  private

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

class ImageException < Exception
end
