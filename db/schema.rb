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

ActiveRecord::Schema.define(version: 2022_07_10_202122) do

  create_table "aircraft", force: :cascade do |t|
    t.string "name", null: false
    t.integer "bts_id", null: false
    t.integer "group", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "airlines", force: :cascade do |t|
    t.string "iata", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "airports", force: :cascade do |t|
    t.string "name", null: false
    t.string "iata", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "counts", force: :cascade do |t|
    t.integer "aircraft_id", null: false
    t.integer "airline_id", null: false
    t.integer "origin_airport_id", null: false
    t.integer "destination_airport_id", null: false
    t.integer "time_period_id", null: false
    t.integer "departures_performed", null: false
    t.integer "departures_scheduled", null: false
    t.integer "seats", null: false
    t.integer "passengers", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["aircraft_id"], name: "index_counts_on_aircraft_id"
    t.index ["airline_id"], name: "index_counts_on_airline_id"
    t.index ["destination_airport_id"], name: "index_counts_on_destination_airport_id"
    t.index ["origin_airport_id"], name: "index_counts_on_origin_airport_id"
    t.index ["time_period_id"], name: "index_counts_on_time_period_id"
  end

  create_table "processed_files", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "time_periods", force: :cascade do |t|
    t.string "name", null: false
    t.integer "year", null: false
    t.integer "month", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
