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
    FileUtils.rm zipfile_name if File.exists? zipfile_name # overwrite
    return zipfile_name if File.exists? zipfile_name

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream("#{@user.username}.json") { |f| f.write JSON.pretty_generate(user_json) }
      # images = @entries.map(&:images).flatten
      # images.each do |image|
      #   zipfile.add image.image_path, image.file_path
      # end

      @entries.each do |entry|
        folder = "#{entry.updated_at.to_date.to_s} #{entry.title}"

        zipfile.get_output_stream("#{folder}/dream.txt") do |f|
          f.write <<-TXT
#{entry.title}
#{entry.type} at #{entry.updated_at}
------------------------------------------------
#{entry.body}
          TXT
        end
        entry.images.each do |image|
          zipfile.add "#{folder}/#{image.filename}", image.file_path
        end
      end
    end
    zipfile_name
  end
end
