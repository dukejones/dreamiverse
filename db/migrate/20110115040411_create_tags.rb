class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.references :entry, :polymorphic => {:default => 'Dream'}
      t.references :noun, :polymorphic => {:default => 'What'}
    end

    create_table :whos do |t|
      t.string :name
      t.column :user, 'bigint' # facebook uid > int field max.
      t.string :user_type # dreamcatcher, facebook, twitter
    end

    create_table :wheres do |t|
      t.string :name, :city, :province, :country
      t.decimal :latitude, :longitude, :precision => 6 # 1/10 of one meter
    end

    create_table :whats do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :tags
    drop_table :whos
    drop_table :wheres
    drop_table :whats
  end
end
