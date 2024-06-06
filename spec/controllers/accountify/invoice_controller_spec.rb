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

    describe 'POST #create' do
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

      let(:invoice) { Models::Invoice.find_by!(id: response_body_json['invoice_id']) }

      let(:event) { invoice.events.find_by!(id: response_body_json['event_id']) }

      it 'returns 201 created with invoice_id and event_id in body' do
        expect(response).to have_http_status(:created)

        expect(response_body_json).to include('invoice_id', 'event_id')
      end

      it 'creates invoice' do
        expect(invoice.persisted?).to be true
      end

      it 'creates event' do
        expect(event.persisted?).to be true
      end
    end

    describe 'GET #show' do
      let(:id) do
        create(:accountify_invoice,
          iam_tenant_id: iam_tenant_id,
          organisation_id: organisation.id,
          contact_id: contact.id,
          currency_code: "AUD",
          status: Invoice::Status::DRAFT,
          due_date: current_date + 30.days,
          sub_total_amount: BigDecimal("600.00"),
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
