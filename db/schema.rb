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

ActiveRecord::Schema[7.1].define(version: 2026_07_28_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competitions", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "promiedos_id"
    t.jsonb "filter_keys"
  end

  create_table "games", force: :cascade do |t|
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.datetime "starts_at"
    t.string "status"
    t.integer "home_score"
    t.integer "away_score"
    t.integer "minute"
    t.string "stadium"
    t.string "city"
    t.string "stage"
    t.integer "fifa_match_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "competition_id"
    t.string "slug"
    t.string "external_id"
    t.string "filter_key"
    t.index ["away_team_id", "starts_at"], name: "index_games_on_away_team_and_starts_at"
    t.index ["competition_id", "starts_at"], name: "index_games_on_competition_and_starts_at"
    t.index ["competition_id"], name: "index_games_on_competition_id"
    t.index ["external_id"], name: "index_games_on_external_id", unique: true
    t.index ["home_team_id", "starts_at"], name: "index_games_on_home_team_and_starts_at"
    t.index ["status", "starts_at"], name: "index_games_on_status_and_starts_at"
  end

  create_table "synchronization_runs", force: :cascade do |t|
    t.string "kind", null: false
    t.string "status", null: false
    t.datetime "started_at", null: false
    t.datetime "finished_at"
    t.integer "duration_ms"
    t.integer "processed_games", default: 0, null: false
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "status", "finished_at"], name: "index_sync_runs_on_kind_status_finished"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "flag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "primary_color"
    t.string "secondary_color"
    t.string "promiedos_id"
    t.string "slug"
    t.index ["slug"], name: "index_teams_on_slug"
  end

  add_foreign_key "games", "competitions"
end
