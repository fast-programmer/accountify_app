require 'rails_helper'

module Accountify
  RSpec.describe InvoiceStatusSummaryService do
    describe '.regenerate' do
      let(:user_id) { 1 }
      let(:tenant_id) { 1 }
      let(:organisation) { create(:accountify_organisation) }
      let(:organisation_id) { organisation.id }
      let(:current_utc_time) { ::Time.now.utc }
      let(:time) { double('Time', now: double('Time', utc: current_utc_time)) }
      let(:invoice_updated_at) { current_utc_time - 1.day }

      let(:contact) do
        create(:accountify_contact,
          tenant_id: tenant_id,
          organisation_id: organisation.id)
      end

      let!(:drafted_invoice) do
        create(:accountify_invoice,
          tenant_id: tenant_id,
          organisation_id: organisation_id,
          contact_id: contact.id,
          status: Invoice::Status::DRAFTED)
      end

      let!(:issued_invoice) do
        create(:accountify_invoice,
          tenant_id: tenant_id,
          organisation_id: organisation_id,
          contact_id: contact.id,
          status: Invoice::Status::ISSUED)
      end

      let!(:paid_invoice) do
        create(:accountify_invoice,
          tenant_id: tenant_id,
          organisation_id: organisation_id,
          contact_id: contact.id,
          status: Invoice::Status::PAID)
      end

      let!(:voided_invoice) do
        create(:accountify_invoice,
          tenant_id: tenant_id,
          organisation_id: organisation_id,
          contact_id: contact.id,
          status: Invoice::Status::VOIDED)
      end

      let(:event) do
        create(
          :accountify_invoice_voided_event,
          user_id: user_id,
          tenant_id: tenant_id,
          eventable: organisation,
          created_at: invoice_updated_at,
          body: { 'organisation' =>  { 'id' => organisation_id } })
      end

      let!(:invoice_status_summary) do
        create(:accountify_invoice_status_summary,
          tenant_id: tenant_id,
          organisation_id: organisation_id,
          generated_at: invoice_updated_at - 1.hour,
          drafted_count: 1,
          issued_count: 1,
          paid_count: 1,
          voided_count: 1)
      end

      it 'updates the existing invoice status summary' do
        expect do
          InvoiceStatusSummaryService.regenerate(event_id: event.id, time: time)
        end.to change { InvoiceStatusSummary.count }.by(0)

        summary = InvoiceStatusSummary.find(invoice_status_summary.id)
        expect(summary.generated_at).to be_within(1.second).of(current_utc_time)
        expect(summary.drafted_count).to eq(1)
        expect(summary.issued_count).to eq(1)
        expect(summary.paid_count).to eq(1)
        expect(summary.voided_count).to eq(1)
      end

      it 'returns the summary if not updated' do
        summary = InvoiceStatusSummaryService.regenerate(
          event_id: event.id,
          invoice_updated_at: current_utc_time - 2.days,
          time: time)

        expect(summary[:generated_at]).to be_within(1.second).of(invoice_updated_at - 1.hour)
      end

      it 'raises Accountify::NotAvailable error on lock wait timeout' do
        allow(InvoiceStatusSummary).to receive(:find_by!)
          .and_raise(ActiveRecord::LockWaitTimeout)

        expect do
          InvoiceStatusSummaryService.regenerate(
            event_id: event.id,
            invoice_updated_at: invoice_updated_at,
            time: time)
        end.to raise_error(Accountify::NotAvailable)
      end

      it 'raises ActiveRecord::RecordNotFound error when summary is not found' do
        allow(InvoiceStatusSummary).to receive(:find_by!)
          .and_raise(ActiveRecord::RecordNotFound)

        expect do
          InvoiceStatusSummaryService.regenerate(
            event_id: event.id,
            invoice_updated_at: invoice_updated_at,
            time: time)
        end.to raise_error(Accountify::NotFound)
      end
    end
  end
end
