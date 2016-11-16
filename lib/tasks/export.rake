
namespace :export do
  desc 'export public dreams to json'
  task :public_dreams_to_json do

    # query public dreams
    Entry.everyone.where(type: 'dream').limit(20).find_each do |entry|
      json = entry.to_export_json
      puts json.to_s

    end
  end
end
