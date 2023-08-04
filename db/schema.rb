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

ActiveRecord::Schema[7.0].define(version: 2023_08_04_164920) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "messages", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.text "body_class_name", null: false
    t.jsonb "body_json", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "outboxer_exceptions", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.text "class_name", null: false
    t.text "message_text", null: false
    t.text "backtrace", array: true
    t.datetime "created_at", null: false
    t.index ["message_id"], name: "index_outboxer_exceptions_on_message_id"
  end

  create_table "outboxer_messages", force: :cascade do |t|
    t.string "message_type", null: false
    t.bigint "message_id", null: false
    t.text "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_type", "message_id"], name: "index_outboxer_messages_on_message"
    t.index ["message_type", "message_id"], name: "index_outboxer_messages_on_message_type_and_message_id", unique: true
    t.index ["status", "created_at"], name: "index_outboxer_messages_on_status_and_created_at"
  end

  add_foreign_key "outboxer_exceptions", "outboxer_messages", column: "message_id"
end
