require 'rails_helper'

module Accountify
  RSpec.describe ContactController, type: :controller do
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

    before do
      request.headers['X-User-Id'] = user_id
      request.headers['X-Tenant-Id'] = tenant_id
    end

    describe 'POST #create' do
      it 'creates a new contact' do
        post :create, params: {
          organisation_id: organisation.id,
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com'
        }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('id')
        expect(JSON.parse(response.body)).to have_key('events')
      end
    end

    describe 'GET #show' do
      it 'returns the contact' do
        get :show, params: { id: contact.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(contact.id)
      end
    end

    describe 'PUT #update' do
      it 'updates the contact' do
        put :update, params: {
          id: contact.id,
          first_name: 'Jane',
          last_name: 'Doe',
          email: 'jane.doe@example.com'
        }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('id')
        expect(JSON.parse(response.body)).to have_key('events')
        contact.reload
        expect(contact.first_name).to eq('Jane')
        expect(contact.last_name).to eq('Doe')
        expect(contact.email).to eq('jane.doe@example.com')
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes the contact' do
        delete :destroy, params: { id: contact.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('id')
        expect(JSON.parse(response.body)).to have_key('events')
        expect(Contact.find_by(deleted_at: nil, id: contact.id)).to be_nil
      end
    end
  end
end
