require 'rails_helper'

module Accountify
  RSpec.describe OrganisationController, type: :controller do
    let(:iam_user_id) { 1 }

    let(:iam_tenant_id) { 1 }

    let(:organisation) do
      create(:accountify_organisation, iam_tenant_id: iam_tenant_id)
    end

    before do
      request.headers['X-Iam-User-Id'] = iam_user_id
      request.headers['X-Iam-Tenant-Id'] = iam_tenant_id
    end

    describe 'POST #create' do
      it 'creates a new organisation' do
        post :create, params: { name: 'New Organisation' }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('organisation_id')
        expect(JSON.parse(response.body)).to have_key('event_id')
      end
    end

    describe 'GET #show' do
      it 'returns the organisation' do
        get :show, params: { id: organisation.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(organisation.id)
      end
    end

    describe 'PUT #update' do
      it 'updates the organisation' do
        put :update, params: { id: organisation.id, name: 'Updated Organisation' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('event_id')
        organisation.reload
        expect(organisation.name).to eq('Updated Organisation')
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes the organisation' do
        delete :destroy, params: { id: organisation.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('event_id')
        expect(
          Models::Organisation.find_by(deleted_at: nil, id: organisation.id)
        ).to be_nil
      end
    end
  end
end
