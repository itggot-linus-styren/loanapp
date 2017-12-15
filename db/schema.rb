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

ActiveRecord::Schema.define(version: 20171128151757) do

  create_table "applock", id: false, force: :cascade do |t|
    t.string "encrypted_password"
  end

  create_table "cars", force: :cascade do |t|
    t.string "name"
    t.string "brand"
    t.string "status"
    t.boolean "deleted"
  end

  create_table "harddrives", force: :cascade do |t|
    t.string "name"
    t.string "brand"
    t.decimal "disksize"
    t.string "status"
    t.boolean "deleted"
  end

  create_table "invitations", force: :cascade do |t|
    t.string "token"
    t.string "user_type"
    t.datetime "expiration_date"
    t.integer "invited_by_id"
    t.integer "used_by_id"
  end

  create_table "loans", force: :cascade do |t|
    t.string "loanable_type"
    t.integer "loanable_id"
    t.string "responsible"
    t.string "purpose"
    t.string "location"
    t.datetime "loaned_at"
    t.datetime "returned_at"
    t.index ["loanable_type", "loanable_id"], name: "index_loans_on_loanable_type_and_loanable_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "user_type"
    t.string "encrypted_password"
    t.datetime "registred_at"
  end

end
