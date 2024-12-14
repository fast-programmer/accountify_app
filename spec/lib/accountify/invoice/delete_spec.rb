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

    let!(:id) do
      create(:accountify_invoice,
        tenant_id: tenant_id,
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: "AUD",
        due_date: current_date + 30.days,
        status: Invoice::Status::DRAFTED,
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

    let!(:invoice) do
      Invoice.delete(user_id: user_id, tenant_id: tenant_id, id: id)
    end

    let(:invoice_model) { Models::Invoice.where(tenant_id: tenant_id).find_by!(id: id) }

    let(:event_model) do
      Invoice::DeletedEvent.where(tenant_id: tenant_id).find_by!(id: invoice[:events].last[:id])
    end

    describe '.delete' do
      it "updates model deleted at" do
        expect(invoice_model.deleted_at).not_to be_nil
      end

      it 'creates deleted event' do
        expect(event_model.body).to include(
          'invoice' => a_hash_including(
            'id' => invoice[:id],
            'deleted_at' => be_present))
      end

      it 'associates event with model' do
        expect(invoice_model.events.last.id).to eq(invoice[:events].last[:id])
      end
    end
  end
end
