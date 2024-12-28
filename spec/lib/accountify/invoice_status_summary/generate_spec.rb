require 'rails_helper'

module Accountify
  RSpec.describe InvoiceStatusSummary do
    describe '.generate' do
      let(:current_utc_time) { ::Time.now.utc }
      let(:time) { double('Time', now: double('Time', utc: current_utc_time)) }

      let(:user_id) { 1 }
      let(:tenant_id) { 2 }
      let(:organisation) { create(:accountify_organisation) }

      let(:event) do
        create(
          :accountify_organisation_created_event,
          user_id: user_id,
          tenant_id: tenant_id,
          eventable: organisation,
          body: { 'organisation' =>  { 'id' => organisation.id } })
      end

      it 'creates a new invoice status summary' do
        expect do
          InvoiceStatusSummary.generate(event_id: event.id)
        end.to change { Models::InvoiceStatusSummary.count }.by(1)
      end

      it 'creates a summary with the correct counts' do
        summary = InvoiceStatusSummary.generate(event_id: event.id)

        expect(summary[:drafted_count]).to eq(0)
        expect(summary[:issued_count]).to eq(0)
        expect(summary[:paid_count]).to eq(0)
        expect(summary[:voided_count]).to eq(0)
      end

      it 'uses the current time as the generated_at time' do
        summary = InvoiceStatusSummary.generate(event_id: event.id, time: time)

        expect(summary[:generated_at]).to be_within(1.second).of(current_utc_time)
      end
    end
  end
end
