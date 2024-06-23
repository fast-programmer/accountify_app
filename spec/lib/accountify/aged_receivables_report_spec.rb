require 'rails_helper'

module Accountify
  RSpec.describe AgedReceivablesReport, type: :module do
    let(:iam_tenant_id) { 4 }
    let(:as_at_date) { Date.parse('2024-06-23') }
    let(:currency_code) { 'AUD' }
    let(:num_periods) { 4 }
    let(:period_frequency) { 1 }
    let(:period_unit) { :month }
    let(:ageing_by) { :due_date }

    let(:aged_receivables_report) do
      AgedReceivablesReport.generate(
        iam_tenant_id: iam_tenant_id,
        as_at_date: as_at_date,
        currency_code: currency_code,
        num_periods: num_periods,
        period_frequency: period_frequency,
        period_unit: period_unit,
        ageing_by: ageing_by
      )
    end

    describe '.generate' do
      it 'calculates ageing periods correctly' do
        expect(aged_receivables_report.periods.size).to eq(num_periods)

        expect(
          aged_receivables_report.periods.map { |p| p.attributes.slice('start_date', 'end_date', 'sub_total') }
        ).to eq([
          {'start_date' => Date.parse('2024-06-23'), 'end_date' => Date.parse('2024-07-22'), 'sub_total' => BigDecimal('0')},
          {'start_date' => Date.parse('2024-07-23'), 'end_date' => Date.parse('2024-08-22'), 'sub_total' => BigDecimal('0')},
          {'start_date' => Date.parse('2024-08-23'), 'end_date' => Date.parse('2024-09-22'), 'sub_total' => BigDecimal('0')},
          {'start_date' => Date.parse('2024-09-23'), 'end_date' => Date.parse('2024-10-22'), 'sub_total' => BigDecimal('0')}
        ])
      end
    end
  end
end
