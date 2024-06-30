require 'rails_helper'

module Accountify
  RSpec.describe AgedReceivablesReport, type: :module do
    describe '.generate' do
      let(:current_date) { Date.parse('2024-06-23') }

      let(:iam_tenant_id) { 4 }

      let(:organisation) do
        create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
      end

      let(:contact) do
        create(:accountify_contact,
          iam_tenant_id: iam_tenant_id, organisation_id: organisation.id)
      end

      let!(:invoice_1) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: "AUD",
          status: Invoice::Status::ISSUED,
          due_date: current_date,
          sub_total_amount: BigDecimal("100.00"),
          sub_total_currency_code: "AUD")
      end

      let!(:invoice_2) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: "AUD",
          status: Invoice::Status::ISSUED,
          due_date: current_date + 1.month,
          sub_total_amount: BigDecimal("200.00"),
          sub_total_currency_code: "AUD")
      end

      let!(:invoice_3) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: "AUD",
          status: Invoice::Status::ISSUED,
          due_date: current_date + 2.months,
          sub_total_amount: BigDecimal("300.00"),
          sub_total_currency_code: "AUD")
      end

      let!(:invoice_4) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: "AUD",
          status: Invoice::Status::ISSUED,
          due_date: current_date + 3.months,
          sub_total_amount: BigDecimal("400.00"),
          sub_total_currency_code: "AUD")
      end

      let(:as_at_date) { Date.parse('2024-06-23') }
      let(:currency_code) { 'AUD' }
      let(:num_periods) { 4 }
      let(:period_amount) { 1 }
      let(:period_unit) { :month }
      let(:ageing_by) { :due_date }

      let(:report) do
        AgedReceivablesReport.generate(
          iam_tenant_id: iam_tenant_id,
          as_at_date: as_at_date,
          currency_code: currency_code,
          num_periods: num_periods,
          period_amount: period_amount,
          period_unit: period_unit,
          ageing_by: ageing_by)
      end

      let(:report_model) do
        Models::AgedReceivablesReport
          .where(iam_tenant_id: iam_tenant_id)
          .find_by!(id: report[:id])
      end

      it 'creates model' do
        expect(
          report_model.attributes.slice(
            'id',
            'as_at_date',
            'currency_code',
            'num_periods',
            'period_amount',
            'period_unit'
          ).merge(
            'periods' => report_model.periods.map do |period|
              period.slice(
                'start_date',
                'end_date',
                'sub_total_amount',
                'sub_total_currency_code')
            end
          )
        ).to eq(
          'id' => report_model.id,
          'as_at_date' => Date.parse('2024-06-23'),
          'currency_code' => 'AUD',
          'num_periods' => 4,
          'period_amount' => 1,
          'period_unit' => 'month',
          'periods' => [
            {
              'start_date' => Date.parse('2024-06-23'),
              'end_date' => Date.parse('2024-07-22'),
              'sub_total_amount' => 100.0,
              'sub_total_currency_code' => 'AUD'
            },
            {
              'start_date' => Date.parse('2024-07-23'),
              'end_date' => Date.parse('2024-08-22'),
              'sub_total_amount' => 200.0,
              'sub_total_currency_code' => 'AUD'
            },
            {
              'start_date' => Date.parse('2024-08-23'),
              'end_date' => Date.parse('2024-09-22'),
              'sub_total_amount' => 300.0,
              'sub_total_currency_code' => 'AUD'
            },
            {
              'start_date' => Date.parse('2024-09-23'),
              'end_date' => Date.parse('2024-10-22'),
              'sub_total_amount' => 400.0,
              'sub_total_currency_code' => 'AUD'
            }
          ]
        )
      end

      it 'returns report' do
        expect(report).to include({
          id: be_a(Integer),
          as_at_date: Date.parse('2024-06-23'),
          currency_code: 'AUD',
          num_periods: 4,
          period_amount: 1,
          period_unit: :month,
          created_at: be_present,
          updated_at: be_present,
          periods: [
            {
              start_date: Date.parse('2024-06-23'),
              end_date: Date.parse('2024-07-22'),
              sub_total: {
                amount: BigDecimal('100.0'),
                currency_code: 'AUD'
              }
            },
            {
              start_date: Date.parse('2024-07-23'),
              end_date: Date.parse('2024-08-22'),
              sub_total: {
                amount: BigDecimal('200.0'),
                currency_code: 'AUD'
              }
            },
            {
              start_date: Date.parse('2024-08-23'),
              end_date: Date.parse('2024-09-22'),
              sub_total: {
                amount: BigDecimal('300.0'),
                currency_code: 'AUD'
              }
            },
            {
              start_date: Date.parse('2024-09-23'),
              end_date: Date.parse('2024-10-22'),
              sub_total: {
                amount: BigDecimal('400.0'),
                currency_code: 'AUD'
              }
            }
          ]
        })
      end

    end
  end
end
