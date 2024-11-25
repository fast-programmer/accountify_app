require 'rails_helper'

module Accountify
  RSpec.describe InvoiceController, type: :controller do
    let(:current_date) { Date.today }

    let(:user_id) { 1 }

    let(:tenant_id) { 1 }

    let(:organisation) do
      create(:accountify_organisation, tenant_id: tenant_id)
    end

    let(:contact) do
      create(:accountify_contact,
        tenant_id: tenant_id,
        organisation_id: organisation.id)
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

    before do
      request.headers['X-User-Id'] = user_id
      request.headers['X-Tenant-Id'] = tenant_id
    end

    let(:response) { patch :paid, params: { id: id } }

    let!(:response_body_json) { JSON.parse(response.body) }

    let(:event) do
      Invoice::PaidEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: response_body_json['events'].last['id'])
    end

    let(:invoice) do
      Models::Invoice.where(tenant_id: tenant_id).find_by!(id: id)
    end

    describe 'PATCH #paid' do
      it 'returns 200 with paid event id in body' do
        expect(response).to have_http_status(:ok)

        expect(JSON.parse(response.body)).to have_key('events')
      end

      it 'updates invoice status to paid' do
        expect(invoice.status).to eq(Invoice::Status::PAID)
      end

      it 'sets invoice paid_at' do
        expect(invoice.paid_at).not_to be_nil
      end

      it 'creates event' do
        expect(event.persisted?).to be true
      end
    end
  end
end
