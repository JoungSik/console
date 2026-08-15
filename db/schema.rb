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

ActiveRecord::Schema[8.1].define(version: 2026_08_16_000000) do
  create_table "push_notification_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: true, null: false
    t.string "item_key", null: false
    t.string "plugin_name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "plugin_name", "item_key"], name: "idx_push_notif_settings_unique", unique: true
    t.index ["user_id"], name: "index_push_notification_settings_on_user_id"
  end

  create_table "push_registrations", force: :cascade do |t|
    t.string "app_version"
    t.datetime "created_at", null: false
    t.string "device_model"
    t.text "firebase_installation_id", null: false
    t.datetime "last_registered_at", null: false
    t.string "os_version"
    t.string "platform", null: false
    t.integer "session_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["firebase_installation_id"], name: "index_push_registrations_on_firebase_installation_id", unique: true
    t.index ["session_id", "platform"], name: "index_push_registrations_on_session_id_and_platform", unique: true
    t.index ["session_id"], name: "index_push_registrations_on_session_id"
    t.index ["user_id"], name: "index_push_registrations_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_plugins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "disabled_at"
    t.boolean "enabled", default: true, null: false
    t.string "plugin_name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "plugin_name"], name: "index_user_plugins_on_user_id_and_plugin_name", unique: true
    t.index ["user_id"], name: "index_user_plugins_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.datetime "email_verified_at"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "theme", default: "system", null: false
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "push_notification_settings", "users"
  add_foreign_key "push_registrations", "sessions"
  add_foreign_key "push_registrations", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_plugins", "users"
end
