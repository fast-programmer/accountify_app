require 'rails_helper'

module Accountify
  RSpec.describe Invoice do
    let(:current_date) { Date.today }

    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:organisation) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
    end

    let(:contact) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant_id, organisation_id: organisation.id)
    end

    let(:result) do
      Invoice.create(
        iam_user_id: iam_user_id,
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: "AUD",
        due_date: current_date + 30.days,
        line_items: [{
          description: "Chair",
          unit_amount: {
            amount: BigDecimal("100.00"),
            currency_code: "AUD" },
          quantity: 1
        }, {
          description: "Table",
          unit_amount: {
            amount: BigDecimal("300.00"),
            currency_code: "AUD" },
          quantity: 3 } ])
    end

    let(:id) { result[0] }

    let(:event_id) { result[1] }

    let(:invoice) do
      Models::Invoice.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)
    end

    let(:event) do
      Invoice::CreatedEvent.where(iam_tenant_id: iam_tenant_id).find_by!(id: event_id)
    end

    describe '.create' do
      it 'creates invoice' do
        expect(invoice.status).to eq(Invoice::Status::DRAFT)
        expect(invoice.currency_code).to eq("AUD")
        expect(invoice.due_date).to eq(current_date + 30.days)

        expect(invoice.line_items).to match_array([
          have_attributes(
            description: "Chair",
            unit_amount_amount: BigDecimal("100.00"),
            unit_amount_currency_code: "AUD",
            quantity: 1),
          have_attributes(
            description: "Table",
            unit_amount_amount: BigDecimal("300.00"),
            unit_amount_currency_code: "AUD",
            quantity: 3),
        ])

        expect(invoice.sub_total_amount).to eq(BigDecimal("1000.00"))
        expect(invoice.sub_total_currency_code).to eq("AUD")
      end

      it 'creates created event' do
        expect(event.body).to eq({
          'invoice' => {
            'id' => id,
            'status' => Invoice::Status::DRAFT,
            'currency_code' => "AUD",
            'due_date' => (current_date + 30.days ).to_s,
            'line_items' => [
              {
                'description' => "Chair",
                'unit_amount_amount' => BigDecimal("100.00").to_s,
                'unit_amount_currency_code' => "AUD",
                'quantity' => 1
              },
              {
                'description' => "Table",
                'unit_amount_amount' => BigDecimal("300.00").to_s,
                'unit_amount_currency_code' => "AUD",
                'quantity' => 3
              }
            ],
            'sub_total' => {
              'amount' => BigDecimal('1000.00').to_s,
              'currency_code' => "AUD" } } })
      end

      it 'associates event with model' do
        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user_id,
                'iam_tenant_id' => iam_tenant_id,
                'id' => event_id,
                'type' => 'Accountify::Invoice::CreatedEvent')])])
      end
    end
  end
end
