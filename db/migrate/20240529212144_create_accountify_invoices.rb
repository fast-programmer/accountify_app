class CreateAccountifyInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_invoices do |t|
      t.bigint :iam_tenant_id, null: false, index: true

      t.references :organisation, null: false,
        foreign_key: { to_table: :accountify_organisations }, index: true

      t.references :contact, null: false,
        foreign_key: { to_table: :accountify_contacts }, index: true

      t.string :status, null: false

      t.string :currency_code

      t.date :due_date

      t.datetime :issued_at

      t.datetime :paid_at

      t.decimal :sub_total_amount, precision: 12, scale: 2
      t.string :sub_total_currency_code

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
