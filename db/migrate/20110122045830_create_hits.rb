class CreateHits < ActiveRecord::Migration
  def self.up
    create_table :hits do |t|
      t.references :user
      t.string :ip_address, :limit => 15 
      t.string :url_path
      t.timestamps
    end
  end

  def self.down
    drop_table :hits
  end
end
