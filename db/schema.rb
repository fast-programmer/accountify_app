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

ActiveRecord::Schema[7.0].define(version: 2024_12_14_080822) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accountify_contacts", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.bigint "organisation_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_accountify_contacts_on_deleted_at"
    t.index ["organisation_id"], name: "index_accountify_contacts_on_organisation_id"
    t.index ["tenant_id"], name: "index_accountify_contacts_on_tenant_id"
  end

  create_table "accountify_invoice_line_items", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.string "description", null: false
    t.integer "quantity", null: false
    t.decimal "unit_amount_amount", precision: 12, scale: 2, null: false
    t.string "unit_amount_currency_code", null: false
    t.index ["invoice_id"], name: "index_accountify_invoice_line_items_on_invoice_id"
  end

  create_table "accountify_invoice_status_summaries", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.bigint "organisation_id", null: false
    t.integer "drafted_count", null: false
    t.integer "issued_count", null: false
    t.integer "paid_count", null: false
    t.integer "voided_count", null: false
    t.datetime "generated_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_accountify_invoice_status_summaries_on_organisation_id"
    t.index ["tenant_id", "organisation_id"], name: "idx_on_tenant_id_organisation_id_33a11db97a", unique: true
  end

  create_table "accountify_invoices", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.bigint "organisation_id", null: false
    t.bigint "contact_id", null: false
    t.string "status", null: false
    t.string "currency_code"
    t.date "due_date"
    t.datetime "issued_at"
    t.datetime "paid_at"
    t.decimal "sub_total_amount", precision: 12, scale: 2
    t.string "sub_total_currency_code"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_accountify_invoices_on_contact_id"
    t.index ["organisation_id"], name: "index_accountify_invoices_on_organisation_id"
    t.index ["tenant_id"], name: "index_accountify_invoices_on_tenant_id"
  end

  create_table "accountify_organisations", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.text "name", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "deleted_at"], name: "index_accountify_organisations_on_tenant_id_and_deleted_at"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tenant_id", null: false
    t.text "type", null: false
    t.text "eventable_type", null: false
    t.bigint "eventable_id", null: false
    t.jsonb "body"
    t.datetime "created_at", null: false
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
  end

  create_table "outboxer_exceptions", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.string "class_name", limit: 255, null: false
    t.text "message_text", null: false
    t.datetime "created_at", null: false
    t.index ["message_id"], name: "index_outboxer_exceptions_on_message_id"
  end

  create_table "outboxer_frames", force: :cascade do |t|
    t.bigint "exception_id", null: false
    t.integer "index", null: false
    t.text "text", null: false
    t.index ["exception_id", "index"], name: "index_outboxer_frames_on_exception_id_and_index", unique: true
    t.index ["exception_id"], name: "index_outboxer_frames_on_exception_id"
  end

  create_table "outboxer_messages", force: :cascade do |t|
    t.string "status", limit: 255, null: false
    t.string "messageable_id", limit: 255, null: false
    t.string "messageable_type", limit: 255, null: false
    t.datetime "queued_at", null: false
    t.datetime "buffered_at"
    t.datetime "publishing_at"
    t.datetime "updated_at", null: false
    t.bigint "publisher_id"
    t.string "publisher_name", limit: 263
    t.index ["publisher_id", "updated_at"], name: "idx_outboxer_pub_id_updated_at"
    t.index ["status", "publisher_id", "updated_at"], name: "idx_outboxer_status_pub_id_updated_at"
    t.index ["status", "updated_at"], name: "idx_outboxer_status_updated_at"
    t.index ["status"], name: "idx_outboxer_status"
  end

  create_table "outboxer_publishers", force: :cascade do |t|
    t.string "name", limit: 263, null: false
    t.string "status", limit: 255, null: false
    t.json "settings", null: false
    t.json "metrics", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "outboxer_settings", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "value", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_outboxer_settings_on_name", unique: true
  end

  create_table "outboxer_signals", force: :cascade do |t|
    t.string "name", limit: 9, null: false
    t.bigint "publisher_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["publisher_id"], name: "index_outboxer_signals_on_publisher_id"
  end

  add_foreign_key "accountify_contacts", "accountify_organisations", column: "organisation_id"
  add_foreign_key "accountify_invoice_line_items", "accountify_invoices", column: "invoice_id"
  add_foreign_key "accountify_invoice_status_summaries", "accountify_organisations", column: "organisation_id"
  add_foreign_key "accountify_invoices", "accountify_contacts", column: "contact_id"
  add_foreign_key "accountify_invoices", "accountify_organisations", column: "organisation_id"
  add_foreign_key "outboxer_exceptions", "outboxer_messages", column: "message_id"
  add_foreign_key "outboxer_frames", "outboxer_exceptions", column: "exception_id"
  add_foreign_key "outboxer_signals", "outboxer_publishers", column: "publisher_id"
end
