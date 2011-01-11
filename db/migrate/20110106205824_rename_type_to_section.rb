class RenameTypeToSection < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.rename :type, :section
    end
  end

  def self.down
    change_table :images do |t|
      t.rename :section, :type
    end
  end
end
