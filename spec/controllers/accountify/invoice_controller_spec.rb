require 'rails_helper'

module Accountify
  RSpec.describe InvoiceController, type: :controller do
    let(:iam_user_id) { 1 }
    let(:iam_tenant_id) { 1 }
    let(:organisation) { create(:accountify_organisation, iam_tenant_id: iam_tenant_id) }
    let(:contact) { create(:accountify_contact, iam_tenant_id: iam_tenant_id, organisation_id: organisation.id) }
    let(:invoice) { create(:accountify_invoice, iam_tenant_id: iam_tenant_id, organisation_id: organisation.id, contact_id: contact.id) }

    before do
      request.headers['X-Iam-User-Id'] = iam_user_id
      request.headers['X-Iam-Tenant-Id'] = iam_tenant_id
    end

    describe 'POST #create' do
      it 'creates a new invoice with line items' do
        post :create, params: {
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: 'USD',
          due_date: '2024-12-31',
          line_items: [
            { description: 'Item 1', quantity: 2, unit_amount_amount: 100.0, 
              unit_amount_currency_code: 'USD' },
            { description: 'Item 2', quantity: 5, unit_amount_amount: 50.0, 
              unit_amount_currency_code: 'USD' }
          ]
        }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('invoice_id')
        expect(JSON.parse(response.body)).to have_key('event_id')
      end
    end

    describe 'GET #show' do
      it 'returns the invoice' do
        get :show, params: { id: invoice.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(invoice.id)
      end
    end

    describe 'PUT #update' do
      it 'updates the invoice with new line items' do
        put :update, params: {
          id: invoice.id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          due_date: '2024-12-31',
          line_items: [
            { description: 'Updated Item 1', quantity: 3, unit_amount_amount: 120.0, 
              unit_amount_currency_code: 'USD' },
            { description: 'Updated Item 2', quantity: 4, unit_amount_amount: 60.0, 
              unit_amount_currency_code: 'USD' }
          ]
        }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('event_id')
        invoice.reload
        expect(invoice.due_date.to_s).to eq('2024-12-31')
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes the invoice' do
        delete :destroy, params: { id: invoice.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('event_id')
        expect(Models::Invoice.find_by(deleted_at: nil, id: invoice.id)).to be_nil
      end
    end

    describe 'POST #approve' do
      it 'approves the invoice' do
        post :approve, params: { id: invoice.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('event_id')
        invoice.reload
        expect(invoice.status).to eq('approved')
      end
    end

    describe 'POST #void' do
      it 'voids the invoice' do
        post :void, params: { id: invoice.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('event_id')
        invoice.reload
        expect(invoice.status).to eq('voided')
      end
    end
  end
end
