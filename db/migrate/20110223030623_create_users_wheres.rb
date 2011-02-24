class CreateUsersWheres < ActiveRecord::Migration
  def self.up
    create_table(:users_wheres, :id => false) do |t|
      t.references :user
      t.references :where
    end
    add_index :users_wheres, [:user_id, :where_id]
  end

  def self.down
    drop_table :users_wheres
  end
end
