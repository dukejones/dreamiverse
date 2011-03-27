class ChangeWheresLatitudeLongitude < ActiveRecord::Migration
  # note - the decimal scale & precisions needs to be reversed because of a rake bug
  def self.up
    change_column(:wheres, :longitude, :decimal, :scale => 6, :precision => 10 )
    change_column(:wheres, :latitude, :decimal,  :scale => 6, :precision => 10 )
  end
 
  def self.down
    change_column(:wheres, :longitude, :decimal, :scale => 0, :precision => 6 )
    change_column(:wheres, :latitude, :decimal, :scale => 0, :precision => 6 )
  end
end
