class CreateAccountifyAgedReceivablesReports < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_aged_receivables_reports do |t|
      t.bigint :iam_tenant_id, null: false, index: { unique: true }

      t.date :as_at_date, null: false
      t.string :currency_code, null: false
      t.integer :num_periods, null: false
      t.integer :period_amount, null: false
      t.string :period_unit, null: false
      t.string :ageing_by, null: false

      t.timestamps
    end
  end
end
