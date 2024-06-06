require 'rails_helper'

module Accountify
  RSpec.describe InvoiceController, type: :controller do
    let(:current_date) { Date.today }

    let(:iam_user_id) { 1 }

    let(:iam_tenant_id) { 1 }

    let(:organisation) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
    end

    let(:contact) do
      create(:accountify_contact,
        iam_tenant_id: iam_tenant_id,
        organisation_id: organisation.id)
    end

    before do
      request.headers['X-Iam-User-Id'] = iam_user_id
      request.headers['X-Iam-Tenant-Id'] = iam_tenant_id
    end

    let(:response) do
      post :create, params: {
        organisation_id: organisation.id,
        contact_id: contact.id,
        currency_code: 'AUD',
        due_date: '2024-12-31',
        line_items: [{
          description: 'Item 1',
          unit_amount: { amount: '100.00', currency_code: 'AUD' },
          quantity: '2'
        }, {
          description: 'Item 2',
          unit_amount: { amount: '50.00', currency_code: 'AUD' },
          quantity: '5' }] }
    end

    let!(:response_body_json) { JSON.parse(response.body) }

    let(:invoice) do
      Models::Invoice
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: response_body_json['id'])
    end

    let(:event) do
      Invoice::DraftedEvent
        .where(iam_tenant_id: iam_tenant_id)
        .find_by!(id: response_body_json['event_id'])
    end

    describe 'POST #create' do
      it 'returns 201 status with id and event_id in body' do
        expect(response).to have_http_status(:created)
        expect(response_body_json).to eq({ 'id' => invoice.id, 'event_id' => event.id })
      end

      it 'creates invoice' do
        expect(invoice.persisted?).to be true
      end

      it 'creates event' do
        expect(event.persisted?).to be true
      end
    end
  end
end
