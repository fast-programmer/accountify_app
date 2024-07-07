require 'rails_helper'

module Accountify
  RSpec.describe InvoiceStatusSummary do
    describe '.generate' do
      let(:iam_tenant_id) { 1 }
      let(:organisation) { create(:accountify_organisation) }
      let(:organisation_id) { organisation.id }
      let(:current_time) { Time.current }

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

      it 'creates a new invoice status summary' do
        expect do
          InvoiceStatusSummary.generate(
            iam_tenant_id: iam_tenant_id,
            organisation_id: organisation_id,
            current_time: current_time)
        end.to change { Models::InvoiceStatusSummary.count }.by(1)
      end

      it 'creates a summary with the correct counts' do
        summary = InvoiceStatusSummary.generate(
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          current_time: current_time)

        expect(summary[:draft_count]).to eq(1)
        expect(summary[:issued_count]).to eq(1)
        expect(summary[:paid_count]).to eq(1)
        expect(summary[:voided_count]).to eq(1)
      end

      it 'uses the current time as the generated_at time' do
        summary = InvoiceStatusSummary.generate(
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id,
          current_time: current_time)

        expect(summary[:generated_at]).to be_within(1.second).of(current_time.utc)
      end
    end
  end
end
