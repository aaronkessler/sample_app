class CreateContactsTags < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts_tags, id: false do |t|
      t.belongs_to :contact, null: false, foreign_key: true
      t.belongs_to :tag,     null: false, foreign_key: true
    end
    add_index :contacts_tags, [:contact_id, :tag_id], unique: true
  end
end
