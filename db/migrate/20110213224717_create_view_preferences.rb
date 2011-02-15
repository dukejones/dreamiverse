class CreateViewPreferences < ActiveRecord::Migration
  def self.up
    create_table :view_preferences do |t|
      t.string :theme
      t.references :image
      t.references :viewable, :polymorphic => true
      t.timestamps
    end
    add_index :view_preferences, [:viewable_id, :viewable_type]

    User.all.each do |user|
      user.create_view_preference
    end
    Entry.all.each do |entry|
      entry.create_view_preference if entry.user?
    end
  end

  def self.down
    drop_table :view_preferences
  end
end
