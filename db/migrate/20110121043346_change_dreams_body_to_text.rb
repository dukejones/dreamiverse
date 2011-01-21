class ChangeDreamsBodyToText < ActiveRecord::Migration
  def self.up
    change_table :dreams do |t|
      t.change :body, :text
    end
  end

  def self.down
    change_table :dreams do |t|
      t.change :body, :string
    end
  end
end
