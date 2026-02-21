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

ActiveRecord::Schema[8.1].define(version: 2026_02_21_000005) do
  create_table "bookmark_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_public", default: false, null: false
    t.integer "links_count", default: 0, null: false
    t.string "title", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["is_public"], name: "index_bookmark_groups_on_is_public"
    t.index ["user_id"], name: "index_bookmark_groups_on_user_id"
  end

  create_table "bookmark_links", force: :cascade do |t|
    t.integer "bookmark_group_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "favicon_url"
    t.string "title", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.text "url", null: false
    t.index ["bookmark_group_id"], name: "index_bookmark_links_on_bookmark_group_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.string "auth_key", null: false
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "todo_items", force: :cascade do |t|
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.date "due_date"
    t.boolean "reminder_sent", default: false, null: false
    t.string "title", limit: 200, null: false
    t.integer "todo_list_id", null: false
    t.datetime "updated_at", null: false
    t.index ["todo_list_id"], name: "index_todo_items_on_todo_list_id"
  end

  create_table "todo_lists", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.string "title", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_todo_lists_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "bookmark_links", "bookmark_groups"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "todo_items", "todo_lists"
end
