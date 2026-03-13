class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :email
      t.string :phone_home
      t.string :phone_work
      t.string :phone_mobile
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.date   :birthday
      t.text   :notes
      t.timestamps
    end
    add_index :contacts, :last_name
    add_index :contacts, :email
  end
end
