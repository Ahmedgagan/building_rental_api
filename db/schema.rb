# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_04_180844) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_details", force: :cascade do |t|
    t.integer "user_id"
    t.string "REN"
    t.boolean "SPA_signed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "announcements", force: :cascade do |t|
    t.string "text"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "booking_details", force: :cascade do |t|
    t.integer "booked_by_user_id"
    t.string "price"
    t.string "name"
    t.string "contact"
    t.string "payment_receipt"
    t.boolean "SPA_signed"
    t.boolean "booking_confirmation"
    t.boolean "is_active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "unit_id"
    t.string "remark"
    t.boolean "disbursement"
    t.boolean "handover"
  end

  create_table "logs", force: :cascade do |t|
    t.string "unit_number"
    t.integer "user_id"
    t.string "action"
    t.integer "admin_user_id"
    t.string "remark"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "unit_details", force: :cascade do |t|
    t.string "unit_block"
    t.string "unit_block_name"
    t.string "unit_number"
    t.string "unit_floor"
    t.string "unit_price"
    t.string "unit_type"
    t.string "unit_view"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "unit_area"
    t.string "unit_furnishing"
    t.string "unit_availability"
    t.boolean "is_booked"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.string "user_type"
    t.string "contact"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_active"
    t.string "token"
  end

end
