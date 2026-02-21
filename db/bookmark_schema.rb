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

ActiveRecord::Schema[8.1].define(version: 2026_02_22_000002) do
  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_public", default: false, null: false
    t.integer "links_count", default: 0, null: false
    t.string "title", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["is_public"], name: "index_groups_on_is_public"
    t.index ["user_id"], name: "index_groups_on_user_id"
  end

  create_table "links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "favicon_url"
    t.integer "group_id", null: false
    t.string "title", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.text "url", null: false
    t.index ["group_id"], name: "index_links_on_group_id"
  end

  add_foreign_key "links", "groups"
end
