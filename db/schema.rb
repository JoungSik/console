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

ActiveRecord::Schema[8.0].define(version: 2025_09_14_082606) do
  create_table "collections", force: :cascade do |t|
    t.string "title", limit: 100, null: false
    t.text "description"
    t.boolean "is_public", default: false, null: false
    t.integer "links_count", default: 0, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "links", force: :cascade do |t|
    t.string "title", limit: 100, null: false
    t.text "url", null: false
    t.text "description"
    t.integer "collection_id", null: false
    t.string "favicon_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_links_on_collection_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "todo_lists", force: :cascade do |t|
    t.string "title", limit: 100, null: false
    t.integer "user_id", null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_todo_lists_on_user_id"
  end

  create_table "todos", force: :cascade do |t|
    t.string "title", limit: 200, null: false
    t.integer "todo_list_id", null: false
    t.boolean "completed", default: false, null: false
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["todo_list_id"], name: "index_todos_on_todo_list_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "collections", "users"
  add_foreign_key "links", "collections"
  add_foreign_key "sessions", "users"
  add_foreign_key "todo_lists", "users"
  add_foreign_key "todos", "todo_lists"
end
