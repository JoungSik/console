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

ActiveRecord::Schema[8.1].define(version: 2026_10_17_234425) do
  create_table "accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "login_id", null: false
    t.string "password", null: false
    t.integer "total_deposit", default: 0, null: false
    t.integer "purchasable", default: 0, null: false
    t.datetime "synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id", unique: true
  end

  create_table "purchase_records", force: :cascade do |t|
    t.integer "account_id", null: false
    t.date "purchased_on"
    t.string "product_name", null: false
    t.integer "round"
    t.string "order_no"
    t.string "barcode"
    t.integer "quantity", default: 0, null: false
    t.string "result"
    t.integer "prize_amount", default: 0, null: false
    t.date "draw_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "purchased_on"], name: "index_purchase_records_on_account_id_and_purchased_on"
    t.index ["account_id"], name: "index_purchase_records_on_account_id"
  end

  create_table "purchase_requests", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_purchase_requests_on_account_id"
    t.index ["token"], name: "index_purchase_requests_on_token", unique: true
  end

  add_foreign_key "purchase_records", "accounts"
  add_foreign_key "purchase_requests", "accounts"
end
