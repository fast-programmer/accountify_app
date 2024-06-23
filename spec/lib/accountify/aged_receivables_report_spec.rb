require 'rails_helper'

module Accountify
  RSpec.describe AgedReceivablesReport, type: :module do
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
        ageing_by: ageing_by)
    end

    describe '.generate' do
      it 'calculates ageing periods correctly' do
        expect(aged_receivables_report.periods.size).to eq(num_periods)

        expect(
          aged_receivables_report.periods.map do |period|
            period.attributes.slice('start_date', 'end_date', 'sub_total')
          end
        ).to eq(
          [
            {
              'start_date' => Date.parse('2024-06-23'),
              'end_date' => Date.parse('2024-07-22'),
              'sub_total' => BigDecimal('100.0')
            },
            {
              'start_date' => Date.parse('2024-07-23'),
              'end_date' => Date.parse('2024-08-22'),
              'sub_total' => BigDecimal('200.0')},
            {
              'start_date' => Date.parse('2024-08-23'),
              'end_date' => Date.parse('2024-09-22'),
              'sub_total' => BigDecimal('300.0')},
            {
              'start_date' => Date.parse('2024-09-23'),
              'end_date' => Date.parse('2024-10-22'),
              'sub_total' => BigDecimal('400.0')
            }
          ]
        )
      end
    end
  end
end
