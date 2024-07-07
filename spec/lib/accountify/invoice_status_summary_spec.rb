require 'rails_helper'

module Accountify
  RSpec.describe InvoiceStatusSummary do
    describe '.generate' do
      let(:iam_tenant_id) { 1 }
      let(:organisation) { create(:accountify_organisation) }
      let(:organisation_id) { organisation.id }
      let(:current_time) { Time.current }

      let!(:draft_invoice) do
        create(:accountify_invoice,
          status: Invoice::Status::DRAFT,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id)
      end

      let!(:issued_invoice) do
        create(:accountify_invoice,
          status: Invoice::Status::ISSUED,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id)
      end

      let!(:paid_invoice) do
        create(:accountify_invoice,
          status: Invoice::Status::PAID,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id)
      end

      let!(:voided_invoice) do
        create(:accountify_invoice,
          status: Invoice::Status::VOIDED,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation_id)
      end

      it 'creates a new invoice status summary' do
        expect {
          InvoiceStatusSummary.generate(
            iam_tenant_id: iam_tenant_id,
            organisation_id: organisation_id,
            current_time: current_time)
        }.to change { Accountify::Models::InvoiceStatusSummary.count }.by(1)
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

      context 'when there are no invoices of a certain status' do
        before do
          Accountify::Models::Invoice.where(status: Invoice::Status::DRAFT).delete_all
        end

        it 'sets the count to 0 for that status' do
          summary = InvoiceStatusSummary.generate(
            iam_tenant_id: iam_tenant_id,
            organisation_id: organisation_id,
            current_time: current_time)

          expect(summary[:draft_count]).to eq(0)
          expect(summary[:issued_count]).to eq(1)
          expect(summary[:paid_count]).to eq(1)
          expect(summary[:voided_count]).to eq(1)
        end
      end
    end
  end
end
