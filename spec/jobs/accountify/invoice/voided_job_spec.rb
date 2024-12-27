
require 'rails_helper'

module Accountify
  module Invoice
    RSpec.describe VoidedJob, type: :job do
      let(:user_id) { 123 }
      let(:tenant_id) { 456 }

      let(:current_time) { Time.now }

      let(:accountify_organisation) do
        create(:accountify_organisation, tenant_id: tenant_id)
      end

      let(:accountify_contact) do
        create(:accountify_contact,
          tenant_id: tenant_id, organisation_id: organisation.id)
      end

      let(:accountify_invoice) do
        create(:accountify_invoice,
          tenant_id: tenant_id, organisation_id: organisation.id, contact_id: contact.id)
      end

      describe 'when Accountify::Models::Invoice::VoidedEvent' do
        let(:event) do
          create(
            :accountify_invoice_voided_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            created_at: current_time.utc,
            body: {
              'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          VoidedJob.new.perform({ 'id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::RegenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::RegenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'tenant_id' => tenant_id,
                  'organisation_id' => accountify_organisation.id,
                  'invoice_updated_at' => event.created_at.utc.iso8601 )])])
        end
      end
    end
  end
end
