require 'rails_helper'

module Accountify
  RSpec.describe Invoice do
    let(:iam_user) { { id: 12 } }
    let(:iam_tenant) { { id: 4 } }

    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant[:id]) }

    let(:contact) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant[:id], organisation_id: organisation.id)
    end

    let(:currency_code) { 'AUD' }

    let(:due_date) { Date.today + 30.days }

    let(:line_items) do
      [
        {
          description: 'Chair',
          quantity: 1,
          unit_amount: {
            amount: BigDecimal("100.00"),
            currency_code: 'AUD'
          }
        },
        {
          description: 'Table',
          quantity: 3,
          unit_amount: {
            amount: BigDecimal("300.00"),
            currency_code: 'AUD'
          }
        }
      ]
    end

    describe '.create' do
      it 'creates invoice' do
        id, _event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          line_items: line_items)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.status).to eq(Invoice::Status::DRAFT)
        expect(invoice.currency_code).to eq(currency_code)
        expect(invoice.due_date).to eq(due_date)

        expect(invoice.line_items).to match_array(
          line_items.map do |line_item|
            have_attributes(
              description: line_item[:description],
              unit_amount_amount: line_item[:unit_amount][:amount],
              unit_amount_currency_code: line_item[:unit_amount][:currency_code],
              quantity: line_item[:quantity])
          end)

        expect(invoice.sub_total_currency_code).to eq(currency_code)
        expect(invoice.sub_total_amount).to eq(BigDecimal("1000.00"))
      end

      it 'creates created event' do
        id, event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          line_items: line_items)

        event = Invoice::CreatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to eq({
          'invoice' => {
            'id' => id,
            'status' => Invoice::Status::DRAFT,
            'currency_code' => currency_code,
            'due_date' => due_date.to_s,
            'line_items' => line_items.map do |line_item|
              {
                'description' => line_item[:description],
                'unit_amount_amount' => line_item[:unit_amount][:amount].to_s,
                'unit_amount_currency_code' => line_item[:unit_amount][:currency_code],
                'quantity' => line_item[:quantity]
              }
            end,
            'sub_total' => {
              'amount' => BigDecimal('1000.00').to_s,
              'currency_code' => currency_code } } })
      end

      it 'associates event with model' do
        id, event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          line_items: line_items)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        _id, event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          line_items: line_items)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Invoice::CreatedEvent')])])
      end
    end
  end
end
