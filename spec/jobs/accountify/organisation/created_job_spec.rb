require 'rails_helper'

module Accountify
  module Organisation
    RSpec.describe CreatedJob, type: :job do
      let(:current_time) { Time.now }

      let(:user_id) { 123 }
      let(:tenant_id) { 456 }

      let(:accountify_organisation) do
        create(:accountify_organisation, tenant_id: tenant_id)
      end

      describe 'when Accountify::Models::Organisation::CreatedEvent' do
        let(:event) do
          create(
            :accountify_organisation_created_event,
            user_id: user_id,
            tenant_id: tenant_id,
            eventable: accountify_organisation,
            body: { 'organisation' =>  { 'id' => accountify_organisation.id } })
        end

        before do
          CreatedJob.new.perform({ 'event_id' => event.id })
        end

        it 'performs Accountify::InvoiceStatusSummary::GenerateJob async' do
          expect(Accountify::InvoiceStatusSummary::GenerateJob.jobs).to match([
            hash_including(
              'args' => [
                hash_including(
                  'event_id' => event.id )])])
        end
      end
    end
  end
end
