class UserExporter
  def initialize(user, entries=nil)
    @user = user
    @entries = entries || @user.entries
  end

  def user_json
    json = @user.as_export_json

    json["entries"] = []
    @entries.each do |entry|
      json["entries"] << entry.as_export_json
    end
    json
  end

  def zipfile_name
    Rails.root.join('tmp', @user.username + '.zip')
  end

  def generate_zip_file
    # FileUtils.rm zipfile_name if File.exists? zipfile_name # overwrite
    return zipfile_name if File.exists? zipfile_name

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream('user_and_dreams.json') { |f| f.write JSON.pretty_generate(user_json) }
      images = @entries.map(&:images).flatten
      images.each do |image|
        zipfile.add image.image_path, image.file_path
      end
    end
    zipfile_name
  end
end
