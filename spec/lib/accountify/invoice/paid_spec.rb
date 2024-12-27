require 'rails_helper'

module Accountify
  RSpec.describe Invoice do
    let(:current_date) { Date.today }

    let(:user_id) { 12 }

    let(:tenant_id) { 4 }

    let(:organisation) do
      create(:accountify_organisation, tenant_id: tenant_id)
    end

    let(:contact) do
      create(:accountify_contact,
        tenant_id: tenant_id, organisation_id: organisation.id)
    end

    let(:id) do
      create(:accountify_invoice,
        tenant_id: tenant_id,
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

    let!(:invoice) do
      Invoice.paid(user_id: user_id, tenant_id: tenant_id, id: id)
    end

    let(:invoice_model) do
      Models::Invoice.where(tenant_id: tenant_id).find_by!(id: id)
    end

    let(:event_model) do
      Models::Invoice::PaidEvent.where(tenant_id: tenant_id).find_by!(id: invoice[:events].last[:id])
    end

    describe '.paid' do
      it "updates model status to PAID" do
        expect(invoice_model.status).to eq(Invoice::Status::PAID)
      end

      it "sets model paid_at" do
        expect(invoice_model.paid_at).to be_present
      end

      it 'creates paid event' do
        expect(event_model.body).to include(
          'invoice' => a_hash_including(
            'id' => invoice[:id],
            'status' => Invoice::Status::PAID,
            'paid_at' => be_present ) )
      end

      it 'associates event with model' do
        expect(invoice_model.events.last.id).to eq(invoice[:events].last[:id])
      end
    end
  end
end
