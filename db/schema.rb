# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151021131848) do

  create_table "items", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "item_name",  limit: 65535
    t.integer  "quantity",   limit: 4
    t.float    "mrp",        limit: 24
    t.integer  "user_id",    limit: 4
  end

  create_table "masters", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "item_name",  limit: 65535
    t.text     "uom",        limit: 65535
    t.integer  "units",      limit: 4
    t.integer  "level",      limit: 4
    t.integer  "conversion", limit: 4
    t.float    "mrp",        limit: 24
  end

  create_table "purchases", force: :cascade do |t|
    t.text     "wholesaler",       limit: 65535
    t.text     "item_name",        limit: 65535
    t.integer  "quantity",         limit: 4
    t.text     "unit_of_measure",  limit: 65535
    t.text     "batch_number",     limit: 65535
    t.date     "expiry_date"
    t.date     "date_of_purchase"
    t.float    "total_price",      limit: 24
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id",          limit: 4
  end

  create_table "sales", force: :cascade do |t|
    t.text     "customer",         limit: 65535
    t.text     "item_name",        limit: 65535
    t.integer  "quantity",         limit: 4
    t.text     "unit_of_measure",  limit: 65535
    t.text     "batch_number",     limit: 65535
    t.date     "expiry_date"
    t.date     "date_of_purchase"
    t.float    "total_price",      limit: 24
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id",          limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               limit: 255, default: "", null: false
    t.string   "encrypted_password",  limit: 255, default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
