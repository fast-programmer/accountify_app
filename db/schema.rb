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

ActiveRecord::Schema[7.0].define(version: 2024_01_14_120827) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "outboxer_exceptions", force: :cascade do |t|
    t.bigint "outboxer_message_id", null: false
    t.string "class_name", null: false
    t.string "message_text", null: false
    t.text "backtrace", array: true
    t.datetime "created_at", null: false
    t.index ["outboxer_message_id"], name: "index_outboxer_exceptions_on_outboxer_message_id"
  end

  create_table "outboxer_messages", force: :cascade do |t|
    t.string "status", null: false
    t.string "outboxer_messageable_type", null: false
    t.bigint "outboxer_messageable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outboxer_messageable_type", "outboxer_messageable_id"], name: "index_outboxer_messages_on_outboxer_messageable"
    t.index ["status", "created_at"], name: "index_outboxer_messages_on_status_and_created_at"
  end

  add_foreign_key "outboxer_exceptions", "outboxer_messages"
end
