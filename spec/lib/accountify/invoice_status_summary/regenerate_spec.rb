require 'rails_helper'

module Accountify
  RSpec.describe InvoiceStatusSummary do
    describe '.regenerate' do
      let(:iam_tenant_id) { 1 }
      let(:organisation) { create(:accountify_organisation) }
      let(:organisation_id) { organisation.id }
      let(:current_time) { Time.current }
      let(:event_created_at) { current_time - 1.day }

      let(:contact) do
        create(:accountify_contact,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id)
      end

      let!(:draft_invoice) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          contact_id: contact.id,
          status: Invoice::Status::DRAFT)
      end

      let!(:issued_invoice) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          contact_id: contact.id,
          status: Invoice::Status::ISSUED)
      end

      let!(:paid_invoice) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          contact_id: contact.id,
          status: Invoice::Status::PAID)
      end

      let!(:voided_invoice) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          contact_id: contact.id,
          status: Invoice::Status::VOIDED)
      end

      let!(:invoice_status_summary) do
        create(:accountify_invoice_status_summary,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          generated_at: event_created_at - 1.hour,
          draft_count: 1,
          issued_count: 1,
          paid_count: 1,
          voided_count: 1)
      end

      it 'updates the existing invoice status summary' do
        expect do
          InvoiceStatusSummary.regenerate(
            iam_tenant_id: iam_tenant_id,
            organisation_id: organisation_id,
            event_created_at: event_created_at,
            current_time: current_time)
        end.to change { Models::InvoiceStatusSummary.count }.by(0)

        summary = Models::InvoiceStatusSummary.find(invoice_status_summary.id)
        expect(summary.generated_at).to be_within(1.second).of(current_time.utc)
        expect(summary.draft_count).to eq(1)
        expect(summary.issued_count).to eq(1)
        expect(summary.paid_count).to eq(1)
        expect(summary.voided_count).to eq(1)
      end

      it 'returns the summary if not updated' do
        summary = InvoiceStatusSummary.regenerate(
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          event_created_at: current_time - 2.days,
          current_time: current_time)

        expect(summary[:generated_at]).to be_within(1.second).of(event_created_at - 1.hour)
      end

      it 'raises Accountify::NotAvailable error on lock wait timeout' do
        allow(Models::InvoiceStatusSummary).to receive(:find_by!)
          .and_raise(ActiveRecord::LockWaitTimeout)

        expect do
          InvoiceStatusSummary.regenerate(
            iam_tenant_id: iam_tenant_id,
            organisation_id: organisation_id,
            event_created_at: event_created_at,
            current_time: current_time)
        end.to raise_error(Accountify::NotAvailable)
      end

      it 'raises ActiveRecord::RecordNotFound error when summary is not found' do
        allow(Models::InvoiceStatusSummary).to receive(:find_by!)
          .and_raise(ActiveRecord::RecordNotFound)

        expect do
          InvoiceStatusSummary.regenerate(
            iam_tenant_id: iam_tenant_id,
            organisation_id: organisation_id,
            event_created_at: event_created_at,
            current_time: current_time)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
