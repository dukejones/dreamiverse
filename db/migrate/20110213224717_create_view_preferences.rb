class CreateViewPreferences < ActiveRecord::Migration
  def self.up
    create_table :view_preferences do |t|
      t.string :theme
      t.references :image
      t.references :viewable, :polymorphic => true
      t.timestamps
    end
    add_index :view_preferences, [:viewable_id, :viewable_type]
  end

  def self.down
    drop_table :view_preferences
  end
end
