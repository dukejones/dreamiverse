class MakeStarlightValueDefaultTo0 < ActiveRecord::Migration
  def self.up
    change_table :starlights do |t|
      t.change :value, :integer, :null => false, :default => 0
    end
  end

  def self.down
    change_table :starlights do |t|
      t.change :value, :integer, :null => true, :default => nil
    end
  end
end
