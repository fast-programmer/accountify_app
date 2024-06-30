class CreateAccountifyAgedReceivablesReportPeriods < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_aged_receivables_report_periods do |t|
      t.references :aged_receivables_report,
        null: false, index: true, foreign_key: { to_table: :accountify_aged_receivables_reports }

      t.date :start_date, null: false
      t.date :end_date, null: false
      t.decimal :sub_total_amount, precision: 12, scale: 2, null: false
      t.string :sub_total_currency_code, null: false

      t.timestamps
    end
  end
end
