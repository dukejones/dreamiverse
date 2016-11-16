class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :email_address
      t.references :user
      t.boolean :open_source
      t.boolean :corporate
      t.boolean :evolutionary
      t.timestamps null: false
    end
  end
end
