class CreateTags < ActiveRecord::Migration
  def self.up

    create_table :tags do |t|
      t.references :entry, :polymorphic => {:default => 'Dream'}
      t.references :noun, :polymorphic => {:default => 'What'} # Who, What, Where
    end

    create_table :whos do |t|
      t.string :name
      t.string :source # dreamcatcher, facebook, nil
      t.column :user, 'bigint' # facebook uid > int field max.
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

# dream.tags.nouns => oakland, whales, duke
# dream.tags.locations => oakland
# dream.tags.things => whales
# dream.tags.users => duke
# Tag.get('whales').entries => dream24, quote123, image876
# Tag.get('whales').dreams => dream24
