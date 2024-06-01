require 'rails_helper'

module Accountify
  RSpec.describe Invoice do
    let(:current_date) { Date.today }

    let(:iam_user_id) { 12 }

    let(:iam_tenant_id) { 4 }

    let(:organisation) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
    end

    let(:contact) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant_id, organisation_id: organisation.id)
    end

    let!(:id) do
      create(:accountify_invoice,
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: "AUD",
        due_date: current_date + 30.days,
        status: Invoice::Status::DRAFT,
        sub_total_amount: BigDecimal("1800.00"),
        sub_total_currency_code: "AUD"
      ).id
    end

    let(:line_item_1) do
      create(:accountify_invoice_line_item,
        invoice_id: id,
        description: "Leather Boots",
        unit_amount_amount: BigDecimal("300.0"),
        unit_amount_currency_code: "AUD",
        quantity: 2)
    end

    let(:line_item_2) do
      create(:accountify_invoice_line_item,
        invoice_id: id,
        description: "White Pants",
        unit_amount_amount: BigDecimal("400.0"),
        unit_amount_currency_code: "AUD",
        quantity: 3)
    end

    let!(:line_items) { [line_item_1, line_item_2] }

    let(:invoice) { Models::Invoice.where(iam_tenant_id: iam_tenant_id).find_by!(id: id) }

    let(:event) do
      Invoice::VoidedEvent.where(iam_tenant_id: iam_tenant_id).find_by!(id: event_id)
    end

    let!(:event_id) do
      Invoice.void(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)
    end

    describe '.void' do
      it "updates model status" do
        expect(invoice.status).to eq(Invoice::Status::VOIDED)
      end

      it 'creates voided event' do
        expect(event.body).to include(
          'invoice' => a_hash_including(
            'id' => id,
            'status' => Invoice::Status::VOIDED))
      end

      it 'associates event with model' do
        expect(invoice.events.last.id).to eq(event_id)
      end

      it 'queues event created job' do
        expect(Event::CreatedJob.jobs).to match([
          hash_including(
            'args' => [
              hash_including(
                'iam_user_id' => iam_user_id,
                'iam_tenant_id' => iam_tenant_id,
                'id' => event_id,
                'type' => 'Accountify::Invoice::VoidedEvent')])])
      end
    end
  end
end
