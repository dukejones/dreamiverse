class ReworkStarlight < ActiveRecord::Migration
  def self.up
    [:users, :entries, :whats].each do |table|
      change_table table do |t|
        t.integer :starlight, :default => 0
        t.integer :cumulative_starlight, :default => 0
      end
    end
    
    change_table :entries do |t|
      t.integer :uniques, :default => 0
    end
  end

  def self.down
    [:users, :entries, :whats].each do |table|
      change_table table do |t|
        t.remove :starlight
        t.remove :cumulative_starlight
      end
    end
    
    change_table :entries do |t|
      t.remove :uniques
    end

  end
end
