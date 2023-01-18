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

ActiveRecord::Schema[7.0].define(version: 2023_01_18_112435) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "carriage_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "carriages", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "carriage_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["carriage_type_id"], name: "index_carriages_on_carriage_type_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name", null: false
    t.string "surname", null: false
    t.string "patronymic", null: false
    t.string "phone_number", null: false
    t.string "passport_code", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["passport_code"], name: "index_profiles_on_passport_code", unique: true
    t.index ["phone_number"], name: "index_profiles_on_phone_number", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.string "value"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "routes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seats", force: :cascade do |t|
    t.string "number"
    t.boolean "is_taken", default: false, null: false
    t.bigint "carriage_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["carriage_id"], name: "index_seats_on_carriage_id"
  end

  create_table "station_order_numbers", force: :cascade do |t|
    t.bigint "route_id", null: false
    t.bigint "station_id", null: false
    t.integer "order_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id", "station_id"], name: "index_station_order_numbers_on_route_id_and_station_id", unique: true
    t.index ["route_id"], name: "index_station_order_numbers_on_route_id"
    t.index ["station_id"], name: "index_station_order_numbers_on_station_id"
  end

  create_table "stations", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_stations_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "carriages", "carriage_types"
  add_foreign_key "profiles", "users"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "seats", "carriages"
  add_foreign_key "station_order_numbers", "routes"
  add_foreign_key "station_order_numbers", "stations"
end
