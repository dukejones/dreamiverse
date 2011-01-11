class CreateDreams < ActiveRecord::Migration
  def self.up
    create_table :dreams do |t|
      t.string :body, :title, :tags
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :dreams
  end
end
