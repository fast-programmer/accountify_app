class CreateAccountifyInvoiceStatusSummary < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_invoice_status_summaries do |t|
      t.bigint :iam_tenant_id, null: false

      t.references :organisation, null: false,
        foreign_key: { to_table: :accountify_organisations }, index: true

      t.integer :draft_count, null: false
      t.integer :issued_count, null: false
      t.integer :paid_count, null: false
      t.integer :voided_count, null: false

      t.datetime :generated_at, null: false

      t.timestamps
    end

    add_index :accountify_invoice_status_summaries, [:iam_tenant_id, :organisation_id], unique: true
  end
end
