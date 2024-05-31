require 'rails_helper'

module Accountify
  RSpec.describe Invoice do
    let(:iam_user) { { id: 12 } }
    let(:iam_tenant) { { id: 4 } }

    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant[:id]) }

    let(:contact) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant[:id], organisation_id: organisation.id)
    end

    let(:currency_code) { 'AUD' }

    let(:due_date) { Date.today + 30.days }

    let(:sub_total) do
      {
        amount: BigDecimal("600.00"),
        currency_code: currency_code
      }
    end

    let(:id) do
      invoice = create(:accountify_invoice, :draft,
        iam_tenant_id: iam_tenant[:id],
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: currency_code,
        due_date: due_date,
        sub_total_amount: sub_total[:amount],
        sub_total_currency_code: sub_total[:currency_code])

      create(:accountify_invoice_line_item,
        invoice_id: invoice.id,
        description: "Leather Boots",
        unit_amount_amount: BigDecimal("300.0"),
        unit_amount_currency_code: currency_code,
        quantity: 2)

      invoice.id
    end

    describe '.find_by_id' do
      it 'returns attributes' do
        invoice = Invoice.find_by_id(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(invoice).to eq({
          id: id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          status: Invoice::Status::DRAFT,
          currency_code: currency_code,
          due_date: due_date,
          line_items: [{
            description: "Leather Boots",
            unit_amount: {
              amount: BigDecimal("300.0"),
              currency_code: currency_code },
            quantity: 2 }],
          sub_total: {
            amount: BigDecimal("600.00"),
            currency_code: currency_code } })
      end
    end
  end
end
