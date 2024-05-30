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

    let(:sub_total_amount) { BigDecimal('1000.00') }
    let(:sub_total_currency_code) { 'AUD' }
    let(:sub_total) do
      {
        amount: sub_total_amount,
        currency_code: sub_total_currency_code
      }
    end

    describe '.create' do
      it 'creates model' do
        id, _event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          sub_total: sub_total)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.status).to eq(Invoice::Status::DRAFT)
        expect(invoice.currency_code).to eq(currency_code)
        expect(invoice.due_date).to eq(due_date)
        expect(invoice.sub_total_amount).to eq(sub_total_amount)
      end

      it 'creates created event' do
        id, event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          sub_total: sub_total)

        event = Invoice::CreatedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to eq({
          'invoice' => {
            'id' => id,
            'status' => Invoice::Status::DRAFT,
            'currency_code' => currency_code,
            'due_date' => due_date.to_s,
            'sub_total' => {
              'amount' => sub_total[:amount].to_s,
              'currency_code' => sub_total[:currency_code] } } })
      end

      it 'associates event with model' do
        id, event_id = Invoice.create(
          iam_user: iam_user, iam_tenant: iam_tenant,
          organisation_id: organisation.id, contact_id: contact.id,
          currency_code: currency_code, due_date: due_date,
          sub_total: sub_total)

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
          sub_total: sub_total)

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
