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

ActiveRecord::Schema[7.1].define(version: 2024_05_27_212747) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accountify_contacts", force: :cascade do |t|
    t.bigint "iam_tenant_id", null: false
    t.bigint "organisation_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_accountify_contacts_on_deleted_at"
    t.index ["iam_tenant_id"], name: "index_accountify_contacts_on_iam_tenant_id"
    t.index ["organisation_id"], name: "index_accountify_contacts_on_organisation_id"
  end

  create_table "accountify_organisations", force: :cascade do |t|
    t.bigint "iam_tenant_id", null: false
    t.text "name", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iam_tenant_id", "deleted_at"], name: "index_accountify_organisations_on_iam_tenant_id_and_deleted_at"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "iam_user_id", null: false
    t.bigint "iam_tenant_id", null: false
    t.text "type", null: false
    t.text "eventable_type", null: false
    t.bigint "eventable_id", null: false
    t.jsonb "body"
    t.datetime "created_at", null: false
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
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

  add_foreign_key "accountify_contacts", "accountify_organisations", column: "organisation_id"
  add_foreign_key "outboxer_exceptions", "outboxer_messages"
end
