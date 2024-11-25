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

    let(:invoice) do
      Invoice.find_by_id(user_id: user_id, tenant_id: tenant_id, id: id)
    end

    describe '.find_by_id' do
      it 'returns attributes' do
        expect(invoice).to eq({
          id: id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          status: Invoice::Status::DRAFTED,
          currency_code: "AUD",
          due_date: (current_date + 30.days).to_s,
          line_items: [{
            description: "Leather Boots",
            unit_amount: {
              amount: BigDecimal("300.0"),
              currency_code: "AUD" },
            quantity: 2
          }, {
            description: "White Pants",
            unit_amount: {
              amount: BigDecimal("400.0"),
              currency_code: "AUD" },
            quantity: 3 }],
          sub_total: {
            amount: BigDecimal("1800.00"),
            currency_code: "AUD" },
          events: []})
      end
    end
  end
end
