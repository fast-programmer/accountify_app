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

    let(:invoice) do
      create(:accountify_invoice,
        tenant_id: tenant_id,
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: "AUD",
        status: Invoice::Status::DRAFT,
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
            quantity: 3) ])
    end

    before do
      request.headers['X-User-Id'] = user_id
      request.headers['X-Tenant-Id'] = tenant_id
    end

    let(:response) { delete :destroy, params: { id: invoice.id } }

    let!(:response_body_json) { JSON.parse(response.body) }

    let(:event) do
      Invoice::DeletedEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: response_body_json['event_id'])
    end

    describe 'DELETE #destroy' do
      it 'returns 200 with deleted event id in body' do
        expect(response).to have_http_status(:ok)

        expect(JSON.parse(response.body)).to have_key('event_id')
      end

      it 'deletes the invoice' do
        expect(
          Models::Invoice
            .where.not(deleted_at: nil)
            .where(tenant_id: tenant_id)
            .exists?(id: invoice.id)
        ).to be true
      end

      it 'creates event' do
        expect(event.persisted?).to be true
      end
    end
  end
end
