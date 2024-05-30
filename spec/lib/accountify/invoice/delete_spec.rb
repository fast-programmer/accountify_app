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

    describe '.delete' do
      let(:id) do
        create(:accountify_invoice, :draft,
          iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: sub_total_amount).id
      end

      it "updates model deleted at" do
        Invoice.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        invoice = Models::Invoice
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: id)

        expect(invoice.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        event_id = Invoice.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        event = Invoice::DeletedEvent
          .where(iam_tenant_id: iam_tenant[:id])
          .find_by!(id: event_id)

        expect(event.body).to include(
          'invoice' => a_hash_including(
            'id' => id,
            'deleted_at' => be_present))
      end

      it 'associates event with model' do
        event_id = Invoice.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        invoice = Models::Invoice.where(iam_tenant_id: iam_tenant[:id]).find_by!(id: id)

        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        event_id = Invoice.delete(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user[:id],
                'iam_tenant_id' => iam_tenant[:id],
                'id' => event_id,
                'type' => 'Accountify::Invoice::DeletedEvent')])])
      end
    end
  end
end
