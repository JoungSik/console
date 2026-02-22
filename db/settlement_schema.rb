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

ActiveRecord::Schema[8.1].define(version: 2026_02_22_000007) do
  create_table "gatherings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "gathering_date"
    t.text "memo"
    t.string "remainder_method", default: "ceil", null: false
    t.string "title", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_gatherings_on_user_id"
  end

  create_table "item_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "item_id", null: false
    t.integer "member_id", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "member_id"], name: "index_item_members_on_item_id_and_member_id", unique: true
    t.index ["item_id"], name: "index_item_members_on_item_id"
    t.index ["member_id"], name: "index_item_members_on_member_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.boolean "is_shared", default: false, null: false
    t.string "name", limit: 100, null: false
    t.integer "quantity", default: 1, null: false
    t.integer "round_id", null: false
    t.datetime "updated_at", null: false
    t.index ["round_id"], name: "index_items_on_round_id"
  end

  create_table "members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "gathering_id", null: false
    t.string "name", limit: 50, null: false
    t.datetime "updated_at", null: false
    t.index ["gathering_id"], name: "index_members_on_gathering_id"
  end

  create_table "round_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "member_id", null: false
    t.integer "round_id", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_round_members_on_member_id"
    t.index ["round_id", "member_id"], name: "index_round_members_on_round_id_and_member_id", unique: true
    t.index ["round_id"], name: "index_round_members_on_round_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "gathering_id", null: false
    t.string "name", limit: 100, null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["gathering_id"], name: "index_rounds_on_gathering_id"
  end

  add_foreign_key "item_members", "items"
  add_foreign_key "item_members", "members"
  add_foreign_key "items", "rounds"
  add_foreign_key "members", "gatherings"
  add_foreign_key "round_members", "members"
  add_foreign_key "round_members", "rounds"
  add_foreign_key "rounds", "gatherings"
end
