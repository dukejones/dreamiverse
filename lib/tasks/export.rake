
namespace :export do
  desc 'export public dreams to json'
  task :public_dreams_to_json do
    
    # query public dreams
    Entry.everyone.where(type: 'dream').find_each do |entry|

      json = entry.to_json({include: {
          user: {only: [:id, :name, :username]}, 
          tags: {only: [:intensity, :kind, :noun_type], include: [:noun]},
          images: { only: [:id] },
        },
        only: [ :id, :title, :body, :updated_at, :sharing_level, :type ]}
      )
      puts json.to_s

    end
  end
end