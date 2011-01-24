class CreateStarlights < ActiveRecord::Migration
  def self.up
    create_table :starlights do |t|
      t.references :entity, :polymorphic => true
      t.integer :value
      t.timestamps
    end
  end

  def self.down
    drop_table :starlights
  end
end
