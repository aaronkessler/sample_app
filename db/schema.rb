# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_01_01_000004) do
  create_table "contacts", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name"
    t.string "email"
    t.string "phone_home"
    t.string "phone_work"
    t.string "phone_mobile"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.date "birthday"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_contacts_on_email"
    t.index ["last_name"], name: "index_contacts_on_last_name"
  end

  create_table "contacts_tags", id: false, force: :cascade do |t|
    t.integer "contact_id", null: false
    t.integer "tag_id", null: false
    t.index ["contact_id", "tag_id"], name: "index_contacts_tags_on_contact_id_and_tag_id", unique: true
    t.index ["contact_id"], name: "index_contacts_tags_on_contact_id"
    t.index ["tag_id"], name: "index_contacts_tags_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "contacts_tags", "contacts"
  add_foreign_key "contacts_tags", "tags"
end
