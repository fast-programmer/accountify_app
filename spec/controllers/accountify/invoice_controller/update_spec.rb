require 'rails_helper'

module Accountify
  RSpec.describe InvoiceController, type: :controller do
    let(:current_date) { Date.today }

    let(:user_id) { 12 }

    let(:tenant_id) { 4 }

    let(:organisation_1) do
      create(:accountify_organisation, tenant_id: tenant_id)
    end

    let(:organisation_2) do
      create(:accountify_organisation, tenant_id: tenant_id)
    end

    let(:contact_1) do
      create(:accountify_contact,
        tenant_id: tenant_id, organisation_id: organisation_1.id)
    end

    let(:contact_2) do
      create(:accountify_contact,
        tenant_id: tenant_id, organisation_id: organisation_2.id)
    end

    let(:id) do
      create(:accountify_invoice,
        tenant_id: tenant_id,
        organisation_id: organisation_1.id,
        contact_id: contact_1.id,
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
            quantity: 3) ]
      ).id
    end

    before do
      request.headers['X-User-Id'] = user_id
      request.headers['X-Tenant-Id'] = tenant_id
    end

    let!(:response) do
      put :update, params: {
        id: id,
        organisation_id: organisation_2.id,
        contact_id: contact_2.id,
        currency_code: 'AUD',
        due_date: current_date + 14.days,
        line_items: [{
          description: 'Green Jumper',
          unit_amount: { amount: '100.00', currency_code: 'AUD' },
          quantity: '3'
        }, {
          description: 'Blue Socks',
          unit_amount: { amount: '50.00', currency_code: 'AUD' },
          quantity: '4' }] }
    end

    let!(:response_body_json) { JSON.parse(response.body) }

    let(:event) do
      Invoice::UpdatedEvent
        .where(tenant_id: tenant_id)
        .find_by!(id: response_body_json['events'].last['id'])
    end

    describe 'PUT #update' do
      it 'returns 200 status with event_id in body' do
        expect(response).to have_http_status(:ok)
        expect(response_body_json).to eq({
          'id' => id,
          'events' => [{ 'id' => event.id, 'type' => event.type }]
        })
      end

      it 'updates model' do
      end

      it 'creates event' do
        expect(event.persisted?).to be true
      end
    end
  end
end
