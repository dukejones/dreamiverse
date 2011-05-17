class ChangeDefaultSettingsDefaults < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change_default :default_entry_type, nil
      t.change_default :default_landing_page, nil
      t.change_default :stream_filter, {}
    end
    
    change_table :view_preferences do |t|
      t.remove :font_size
      t.string :font_size, :default => 'medium'
      
      t.remove :menu_style
      t.string :menu_style, :default => 'float'
    end
  end

  def self.down
    change_table :users do |t|
      t.change_default :stream_filter, nil
    end
    
    change_table :view_preferences do |t|
      t.remove :font_size
      t.string :font_size, :default => nil
      
      t.remove :menu_style
      t.string :menu_style, :default => nil
    end
  end
end
