class ChangeTagScoreToPosition < ActiveRecord::Migration
  def self.up
    change_table :tags do |t|
      t.rename :score, :position
      t.change :kind, :string, :default => 'custom', :null => false
    end
  end

  def self.down
    change_table :tags do |t|
      t.rename :position, :score
      t.change :kind, :string
    end
  end
end
