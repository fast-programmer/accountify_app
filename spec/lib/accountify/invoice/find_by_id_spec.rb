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

    let(:sub_total_amount) { BigDecimal('1000.00') }
    let(:sub_total_currency_code) { 'AUD' }
    let(:sub_total) do
      {
        amount: sub_total_amount,
        currency_code: sub_total_currency_code
      }
    end

    describe '.find_by_id' do
      let(:id) do
        create(:accountify_invoice, :draft,
          iam_tenant_id: iam_tenant[:id],
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: currency_code,
          due_date: due_date,
          sub_total_amount: sub_total_amount
        ).id
      end

      it 'returns attributes' do
        invoice = Invoice.find_by_id(iam_user: iam_user, iam_tenant: iam_tenant, id: id)

        expect(invoice).to eq({
          id: id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          status: Invoice::Status::DRAFT,
          currency_code: currency_code,
          due_date: due_date,
          sub_total: {
            amount: sub_total[:amount],
            currency_code: sub_total[:currency_code ]} })
      end
    end
  end
end
