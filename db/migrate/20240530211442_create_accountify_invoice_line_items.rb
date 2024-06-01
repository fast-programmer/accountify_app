class CreateAccountifyInvoiceLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_invoice_line_items do |t|
      t.references :invoice,
        null: false, index: true, foreign_key: { to_table: :accountify_invoices }

      t.string :description, null: false
      t.integer :quantity, null: false

      t.decimal :unit_amount_amount, precision: 12, scale: 2, null: false
      t.string :unit_amount_currency_code, null: false
    end
  end
end
