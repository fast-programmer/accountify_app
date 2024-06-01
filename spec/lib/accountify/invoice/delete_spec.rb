require 'rails_helper'

module Accountify
  RSpec.describe Invoice do
    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:organisation) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
    end

    let(:contact) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant_id, organisation_id: organisation.id)
    end

    let(:id) do
      create(:accountify_invoice,
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: currency_code,
        due_date: due_date,
        sub_total_amount: sub_total_amount
      ).id
    end

    describe '.delete' do
      it "updates model deleted at" do
        Invoice.delete(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)

        invoice = Models::Invoice.where(iam_tenant_id: iam_tenant[:id]).find_by!(id: id)

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
