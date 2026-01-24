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

ActiveRecord::Schema[8.1].define(version: 2026_01_24_162306) do
  create_table "calendar_events", force: :cascade do |t|
    t.string "calendar_id"
    t.datetime "created_at", null: false
    t.string "event_id"
    t.datetime "last_synced_at"
    t.string "provider"
    t.string "refresh_token"
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_calendar_events_on_team_id"
  end

  create_table "lunches", force: :cascade do |t|
    t.boolean "booked"
    t.text "booked_details"
    t.datetime "created_at", null: false
    t.datetime "occurred_at"
    t.integer "restaurant_id", null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_lunches_on_restaurant_id"
    t.index ["team_id"], name: "index_lunches_on_team_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "price_level"
    t.string "primary_type"
    t.float "rating"
    t.json "types", default: []
    t.datetime "updated_at", null: false
    t.integer "user_ratings_count"
  end

  create_table "team_restaurants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "restaurant_id", null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_team_restaurants_on_restaurant_id"
    t.index ["team_id"], name: "index_team_restaurants_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.float "latitude"
    t.float "longiute"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "calendar_events", "teams"
  add_foreign_key "lunches", "restaurants"
  add_foreign_key "lunches", "teams"
  add_foreign_key "team_restaurants", "restaurants"
  add_foreign_key "team_restaurants", "teams"
end
