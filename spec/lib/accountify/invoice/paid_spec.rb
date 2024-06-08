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

    let(:id) do
      create(:accountify_invoice,
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: "AUD",
        status: Invoice::Status::ISSUED,
        due_date: current_date + 30.days,
        sub_total_amount: BigDecimal("600.00"),
        sub_total_currency_code: "AUD",
        line_items: [
          build(:accountify_invoice_line_item,
            description: "Leather Boots",
            unit_amount_amount: BigDecimal("300.0"),
            unit_amount_currency_code: "AUD",
            quantity: 2),
          build(:accountify_invoice_line_item,
            description: "White Pants",
            unit_amount_amount: BigDecimal("400.0"),
            unit_amount_currency_code: "AUD",
            quantity: 3) ]
      ).id
    end

    let!(:event_id) do
      Invoice.paid(iam_user_id: iam_user_id, iam_tenant_id: iam_tenant_id, id: id)
    end

    let(:invoice) do
      Models::Invoice.where(iam_tenant_id: iam_tenant_id).find_by!(id: id)
    end

    let(:event) do
      Invoice::PaidEvent.where(iam_tenant_id: iam_tenant_id).find_by!(id: event_id)
    end

    describe '.paid' do
      it "updates model status to PAID" do
        expect(invoice.status).to eq(Invoice::Status::PAID)
      end

      it 'creates paid event' do
        expect(event.body).to include(
          'invoice' => a_hash_including(
            'id' => id,
            'status' => Invoice::Status::PAID))
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
                'type' => 'Accountify::Invoice::PaidEvent')])])
      end
    end
  end
end
