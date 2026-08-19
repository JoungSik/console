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

ActiveRecord::Schema[8.1].define(version: 2026_08_19_000002) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "notices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_on"
    t.integer "position", null: false
    t.date "published_on", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "push_notification_logs", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "failure_count", default: 0, null: false
    t.string "item_key"
    t.string "plugin_name"
    t.datetime "requested_at", null: false
    t.string "status", default: "pending", null: false
    t.integer "success_count", default: 0, null: false
    t.integer "target_count", default: 0, null: false
    t.json "targets", default: [], null: false
    t.text "title", null: false
    t.datetime "updated_at", null: false
    t.text "url"
    t.integer "user_id", null: false
    t.index ["status"], name: "index_push_notification_logs_on_status"
    t.index ["user_id", "requested_at"], name: "index_push_notification_logs_on_user_id_and_requested_at"
    t.index ["user_id"], name: "index_push_notification_logs_on_user_id"
  end

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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "push_notification_logs", "users"
  add_foreign_key "push_notification_settings", "users"
  add_foreign_key "push_registrations", "sessions"
  add_foreign_key "push_registrations", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_plugins", "users"
end
