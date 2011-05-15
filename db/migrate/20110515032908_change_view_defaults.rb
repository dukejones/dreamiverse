class ChangeViewDefaults < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change_default :default_entry_type, :default => nil
      t.change_default :default_landing_page, :default => nil

      t.remove :default_font_size
      t.remove :default_stream_entry_type_filter
      t.remove :default_stream_users_filter
      t.remove :default_menu_style

      # Not perfect, but let's just store a serialized hash to allow filters to change without having to change the model.
      t.string :stream_filter  
    end
    
    change_table :view_preferences do |t|
      t.remove :default_genre
      t.column :font_size, :string
      t.column :menu_style, :string
    end
  end

  def self.down
    change_table :users do |t|
      t.column :default_font_size, :string
      t.column :default_stream_entry_type_filter, :string
      t.column :default_stream_users_filter, :string
      t.column :default_menu_style, :string
      
      t.remove :stream_filter
    end
    
    change_table :view_preferences do |t|
      t.column :default_genre, :string
      t.remove :font_size
      t.remove :menu_style
    end
  end
end
