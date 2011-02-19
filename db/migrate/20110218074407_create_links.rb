class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string :url, :null => false
      t.string :title, :null => false
      t.references :owner, :polymorphic => true
      t.timestamps
    end
    add_index :links, [:owner_id, :owner_type]
  end

  def self.down
    drop_table :links
  end
end
